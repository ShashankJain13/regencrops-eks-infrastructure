locals {
  application_name     = "regencrops"
  primary_short_region = "aps1"
  primary_region       = "ap-south-1"
  tags = {
    "ApplicationId" = "${local.application_name}"
    "ManagedBy"     = "terraform"
    "CreatedBy"     = "shashank.jain@kisanwala.com"
    "ModifiedBy"    = "shashank.jain@kisanwala.com"
    "AppEnv"        = "${var.AppEnv}"
    "KMS"           = "RW"
    "Description"   = "${var.AppEnv} EKS Cluster for ${local.application_name} application"
    "GitRepo"       = "regencrops-eks-infrastructure"
    "GitBranch"     = "${local.GitBranch}"
  }

  GitBranch     = var.AppEnv == "prd" ? "main" : "development"
  vpc_id        = var.create_vpc == true ? module.eks_vpc[0].vpc_id : var.vpc_id
  vpc_subnet_id = var.create_vpc == true ? module.eks_vpc[0].private_subnets : var.vpc_subnet_id

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_user_arn   = data.aws_caller_identity.current.arn

  cluster_version = "1.29"
  cluster_name    = "${local.application_name}-${var.AppEnv}-eks-app-${local.primary_short_region}"

  #cluster_access_role_arn           = var.cluster_access_role_arn
  aws_load_balancer_controller_role = "${local.cluster_name}-alb-controller-role"
  external_dns_role                 = "${local.cluster_name}-external-dns-role"
  external_secrets_role             = "${local.cluster_name}-external-secrets-role"



  app_service_account = "${local.application_name}-svc-acct"
  app_namespace       = "ns-${local.application_name}"
  aws_pod_role        = "${local.application_name}-${var.AppEnv}-eks-pod-role"
  app_pod_role_policy = "${local.application_name}-${var.AppEnv}-eks-pod-role-policy"


  route53_domain = "${var.AppEnv}.regencrops.aws"

  k8s_kube_system_namespace                 = "kube-system"
  k8s_aws_lb_service_account_name           = "aws-load-balancer-controller"
  k8s_external_dns_service_account_name     = "external-dns"
  k8s_external_secrets_service_account_name = "external-secrets"

  k8s_cluster_name            = module.eks.cluster_name
  k8s_cluster_ca_certificate  = base64decode(module.eks.cluster_certificate_authority_data)
  k8s_cluster_endpoint        = module.eks.cluster_endpoint
  k8s_cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  prometheus_namespace       = "prometheus"
  prometheus_hostname        = "prometheus.${var.AppEnv}.regencrops.aws"
  prometheus_certificate_arn = "arn:aws:acm:ap-south-1:${local.aws_account_id}:certificate/64efa766-243d-4834-a179-67687171f876"

  external_secrets_settings = {}
}
