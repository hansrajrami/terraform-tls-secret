provider "tls" {
    
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "obortech-staging"
}