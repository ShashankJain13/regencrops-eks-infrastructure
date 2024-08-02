resource "kubernetes_service_account" "app-service-account" {
  metadata {
    name      = local.app_service_account
    namespace = local.app_namespace
    labels = {
      "app.kubernetes.io/name"         = local.app_service_account
      "app.kubernetes.io/ResourceName" = local.app_service_account
      "app.kubernetes.io/instance"     = local.app_service_account
      "app.kubernetes.io/component"    = "service-account"
      "app.kubernetes.io/ResourceType" = "service-account"
      "app.kubernetes.io/managed-by"   = "Terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.app_pod_iam_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
  automount_service_account_token = true

  depends_on = [
    module.eks,
    aws_iam_role.app_pod_iam_role,
    kubernetes_namespace.main
  ]
}

resource "kubernetes_secret" "app-service-account-secret" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.app-service-account.metadata.0.name
    }
    namespace = local.app_namespace
    labels = {
      "app.kubernetes.io/ResourceName" = local.app_service_account
      "app.kubernetes.io/ResourceType" = "service-account"
      "app.kubernetes.io/managed-by"   = "Terraform"
    }
    generate_name = "${kubernetes_service_account.app-service-account.metadata.0.name}-token"
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

