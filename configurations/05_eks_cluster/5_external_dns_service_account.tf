resource "kubernetes_service_account" "external-dns-service-account" {
  metadata {
    name      = local.k8s_external_dns_service_account_name
    namespace = local.k8s_kube_system_namespace
    labels = {
      "app.kubernetes.io/name"       = local.k8s_external_dns_service_account_name
      "app.kubernetes.io/instance"   = local.k8s_external_dns_service_account_name
      "app.kubernetes.io/component"  = "service-account"
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.external_dns_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
      "meta.helm.sh/release-name"                = local.k8s_external_dns_service_account_name
      "meta.helm.sh/release-namespace"           = local.k8s_kube_system_namespace
    }
  }
  depends_on = [
    module.eks,
    module.external_dns_role
  ]
}
