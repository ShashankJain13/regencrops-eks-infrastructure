resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = local.k8s_kube_system_namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_role.iam_role_arn
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "zoneType"
    value = "public"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "domainFilters[0]"
    value = local.route53_domain
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "txtOwnerId" #TXT record identifier
    value = "external-dns"
  }

  depends_on = [
    module.eks,
    kubernetes_namespace.main
  ]
}
