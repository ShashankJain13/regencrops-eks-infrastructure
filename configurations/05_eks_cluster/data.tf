provider "kubernetes" {
  host                   = local.k8s_cluster_endpoint
  cluster_ca_certificate = local.k8s_cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.k8s_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = local.k8s_cluster_endpoint
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.k8s_cluster_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = local.k8s_cluster_endpoint
  cluster_ca_certificate = local.k8s_cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.k8s_cluster_name]
    command     = "aws"
  }
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "cluster_ca_certificate" {
  url = local.k8s_cluster_oidc_issuer_url
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.k8s_cluster_name
  depends_on = [ module.eks ]
}

data "aws_iam_openid_connect_provider" "cluster_oidc_provider" {
  url = local.k8s_cluster_oidc_issuer_url
  depends_on = [ module.eks ]
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${local.cluster_version}-v*"]
  }
}

