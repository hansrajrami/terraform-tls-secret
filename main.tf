resource "tls_private_key" "ca_priv_key" {
    algorithm = "RSA"
    rsa_bits = 1024
}

resource "tls_self_signed_cert" "ca_cert" {
    key_algorithm = "${tls_private_key.ca_priv_key.algorithm}"
    private_key_pem = "${tls_private_key.ca_priv_key.private_key_pem}"

    subject {
        common_name  = "Vault CA"
        organization = "Hashicorp Vault"
    }

    validity_period_hours = 876000

    allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
        "cert_signing",
        "client_auth",
    ]

    is_ca_certificate = true
}

resource "tls_private_key" "server_priv_key" {
    algorithm = "RSA"
    rsa_bits = 1024
}

resource "tls_cert_request" "server_cert_request" {
    key_algorithm = "${tls_private_key.server_priv_key.algorithm}"
    private_key_pem = "${tls_private_key.server_priv_key.private_key_pem}"

    subject {
        common_name  = "Vault Server"
        organization = "Hashicorp Vault"
    }

    dns_names = [
        "localhost",
        "*.vault.svc.cluster.local"
    ]

    ip_addresses = [
        "127.0.0.1",
        "::1",
    ]
}

resource "tls_locally_signed_cert" "server_cert" {
    cert_request_pem = "${tls_cert_request.server_cert_request.cert_request_pem}"
    ca_key_algorithm = "${tls_private_key.ca_priv_key.algorithm}"
    ca_private_key_pem = "${tls_private_key.ca_priv_key.private_key_pem}"
    ca_cert_pem = "${tls_self_signed_cert.ca_cert.cert_pem}"

    validity_period_hours = 876000

    allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
        "client_auth",
    ]

    set_subject_key_id = true
}

module "kconfig" {
    source = "./modules/eks_kubeconfig"
    cluster_name = "obortech-staging"
    region = "${var.region}"
    profile = "${var.profile}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

resource "local_file" "kconfig_file" {
    filename = "eks_k8config"
    content = "./kubeconfig-${var.cluster_name}"
}

resource "kubernetes_namespace" "tls_cert_test" {
  metadata {
    name = "tlscerttest"
  }
}

resource "kubernetes_secret_v1" "tls_ca" {
  metadata {
    name = "tls-ca"
    namespace = "tlscerttest"
  }

  type = "kubernetes.io/tls"

  data = {
      "tls.crt" = "${tls_private_key.ca_priv_key.private_key_pem}"
      "tls.key" = "${tls_self_signed_cert.ca_cert.cert_pem}"
  }
}

resource "kubernetes_secret_v1" "tls_server" {
  metadata {
    name = "tls-server"
    namespace = "tlscerttest"
  } 

  type = "kubernetes.io/tls"

    data = {
      "tls.crt" = "${tls_private_key.server_priv_key.private_key_pem}"
      "tls.key" = "${tls_locally_signed_cert.server_cert.cert_pem}"
  }
}

