resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = local.k8s_aws_lb_service_account_name
  namespace  = local.k8s_kube_system_namespace
  version    = "1.4.1"

  set {
    name  = "image.tag"
    value = "v2.4.2"
  }
  set {
    name  = "clusterName"
    value = local.k8s_cluster_name
  }

  set {
    name  = "region"
    value = local.primary_region
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.k8s_aws_lb_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_role.iam_role_arn
  }

  depends_on = [
    module.eks,
    module.aws_load_balancer_controller_role,
    kubernetes_service_account.service-account
  ]
}
