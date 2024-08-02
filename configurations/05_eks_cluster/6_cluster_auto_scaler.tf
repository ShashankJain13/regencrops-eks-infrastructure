module "eks-cluster-autoscaler" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "2.2.0"
  count = var.AppEnv == "prd" ? 1 : 0

  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = data.aws_iam_openid_connect_provider.cluster_oidc_provider.url
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.cluster_oidc_provider.arn

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false
  irsa_role_create  = true

  depends_on = [
    module.eks
  ]
}
