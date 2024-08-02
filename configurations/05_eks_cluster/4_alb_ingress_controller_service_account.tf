resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = local.k8s_aws_lb_service_account_name
    namespace = local.k8s_kube_system_namespace
    labels = {
      "app.kubernetes.io/name"       = local.k8s_aws_lb_service_account_name
      "app.kubernetes.io/instance"   = local.k8s_aws_lb_service_account_name
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.aws_load_balancer_controller_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
      "meta.helm.sh/release-name"                = local.k8s_aws_lb_service_account_name
      "meta.helm.sh/release-namespace"           = local.k8s_kube_system_namespace
    }
  }
  depends_on = [
    module.eks,
    module.aws_load_balancer_controller_role
  ]
}
