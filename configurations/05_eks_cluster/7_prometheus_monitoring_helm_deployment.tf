resource "kubernetes_namespace" "prometheus-namespace" {
  depends_on = [
    module.eks
  ]
  metadata {
    name = local.prometheus_namespace
    annotations = {
      name = local.prometheus_namespace
    }
  }

}

# resource "kubernetes_ingress_v1" "prometheus-ingress" {
#   wait_for_load_balancer = true
#   depends_on = [
#     kubernetes_namespace.prometheus-namespace
#   ]
#   metadata {
#     name      = "prometheus-load-balancer"
#     namespace = "prometheus"

#     labels = {
#       "app.kubernetes.io/ResourceName" = "prometheus"
#       "app.kubernetes.io/ResourceType" = "ingress"
#       "app.kubernetes.io/managed-by"   = "Terraform"
#     }
#     annotations = {
#       "kubernetes.io/ingress.class"                    = "alb"
#       "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type"          = "ip"
#       "alb.ingress.kubernetes.io/healthcheck-path"     = "/graph"
#       "alb.ingress.kubernetes.io/listen-port"          = "[{\"HTTP\":9090,\"HTTPS\":443},{\"HTTP\":80]"
#       "alb.ingress.kubernetes.io/certificate-arn"      = local.prometheus_certificate_arn
#       "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
#       "alb.ingress.kubernetes.io/inbound-cidrs"        = "0.0.0.0/8"
#       "external-dns.alpha.kubernetes.io/hostname"      = local.prometheus_hostname
#     }
#   }
#   spec {
#     rule {
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "ssl-redirect"
#               port {
#                 name = "use-annotation"
#               }
#             }

#           }
#         }
#         path {
#           path = "/*"
#           backend {
#             service {
#               name = "prometheus-server"
#               port {
#                 number = 443
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

resource "helm_release" "prometheus" {
  name       = local.prometheus_namespace
  namespace  = kubernetes_namespace.prometheus-namespace.id
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.2"
  values     = [file("7_prometheus_values_v58.yaml")]
  timeout    = 2000

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }


  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
  depends_on = [
    module.eks,
    kubernetes_namespace.prometheus-namespace
  ]
}
