output "ca_priv_key_pem" {
    value = "${tls_private_key.ca_priv_key.private_key_pem}"
    sensitive = true
}

output "ca_cert_pem" {
    value = "${tls_self_signed_cert.ca_cert.cert_pem}"
}

output "server_priv_key_pem" {
    value = "${tls_private_key.server_priv_key.private_key_pem}"
    sensitive = true
}

output "server_cert_pem" {
    value = "${tls_locally_signed_cert.server_cert.cert_pem}"
}