resource "kubernetes_namespace" "main" {
  metadata {
    annotations = {
      name = "ns-${local.application_name}"
    }

    labels = {
      envrionment = "${var.AppEnv}"
    }

    name = "ns-${local.application_name}"
  }
    depends_on = [
    module.eks
  ]
}
