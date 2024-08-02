module "external_dns_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                  = local.external_dns_role
  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.cluster_oidc_provider.arn
      namespace_service_accounts = ["${local.k8s_kube_system_namespace}:${local.k8s_external_dns_service_account_name}"]
    }
  }
}
