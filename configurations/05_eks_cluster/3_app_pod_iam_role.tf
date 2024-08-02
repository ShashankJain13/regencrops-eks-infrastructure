# data "aws_iam_policy_document" "app_pod_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(data.aws_iam_openid_connect_provider.cluster_oidc_provider.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:${local.app_namespace}:${local.app_service_account}"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(data.aws_iam_openid_connect_provider.cluster_oidc_provider.url, "https://", "")}:aud"
#       values   = ["sts.amazonaws.com"]
#     }

#     principals {
#       identifiers = [data.aws_iam_openid_connect_provider.cluster_oidc_provider.arn]
#       type        = "Federated"
#     }
#   }
# }


data "aws_iam_policy_document" "app_pod_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "app_pod_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.app_pod_assume_role_policy.json
  name               = local.aws_pod_role
  tags               = local.tags
}

resource "aws_iam_policy" "app_pod_iam_role_policy" {
  policy      = local.app_pod_role_policy_json
  description = "Policy for the EKS pod role"
  name        = local.app_pod_role_policy
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "app_pod_iam_role_policy_attachment" {
  role       = aws_iam_role.app_pod_iam_role.name
  policy_arn = aws_iam_policy.app_pod_iam_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "app_pod_iam_role_aws_read_only_policy_attachment" {
  role       = aws_iam_role.app_pod_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_eks_pod_identity_association" "app_pod_iam_role_association" {
  cluster_name    = module.eks.cluster_name
  namespace       = local.app_namespace
  service_account = local.app_service_account
  role_arn        = aws_iam_role.app_pod_iam_role.arn  
}
