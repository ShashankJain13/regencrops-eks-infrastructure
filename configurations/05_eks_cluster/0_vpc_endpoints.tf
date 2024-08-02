resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  service_name      = "com.amazonaws.${local.primary_region}.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id            = local.vpc_id
  route_table_ids   = module.eks_vpc[0].private_route_table_ids
  tags = merge(
    local.tags,
    {
      "Description" = "VPC Endpoint for S3 in ${local.primary_region} region"
    }
  )
}
