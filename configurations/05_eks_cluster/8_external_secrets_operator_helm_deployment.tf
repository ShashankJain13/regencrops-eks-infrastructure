resource "kubernetes_namespace" "external-secrets-namespace" {
  depends_on = [
    module.eks
  ]
  metadata {
    name = local.k8s_external_secrets_service_account_name
    annotations = {
      name = local.k8s_external_secrets_service_account_name
    }
  }

}


resource "helm_release" "external-secrets" {
  name       = local.k8s_external_secrets_service_account_name
  chart      = local.k8s_external_secrets_service_account_name
  repository = "https://charts.external-secrets.io"
  version    = "0.9.16"
  namespace  = kubernetes_namespace.external-secrets-namespace.id

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_secrets_role.iam_role_arn
  }

  values = [
    yamlencode(local.external_secrets_settings)
  ]
  depends_on = [
    kubernetes_namespace.external-secrets-namespace
  ]
}
