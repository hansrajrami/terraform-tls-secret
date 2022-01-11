provider "tls" {
    
}

provider "aws" {
    region = var.region
    // profile = var.profile
    access_key = var.access_key
    secret_key = var.secret_key
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}
