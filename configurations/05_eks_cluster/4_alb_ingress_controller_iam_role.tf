module "aws_load_balancer_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = local.aws_load_balancer_controller_role
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.cluster_oidc_provider.arn
      namespace_service_accounts = ["${local.k8s_kube_system_namespace}:${local.k8s_aws_lb_service_account_name}"]
    }
  }
}
