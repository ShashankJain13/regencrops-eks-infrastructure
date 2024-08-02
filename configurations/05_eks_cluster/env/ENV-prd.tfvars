AppEnv                      = "prd"
kms_key_id                  = "arn:aws:kms:ap-south-1:058264546862:key/mrk-7766e2ee304447819a6e8a8fc8c0e748"
create_vpc                  = true
vpc_cidr_block              = "10.0.0.0/16"
private_subnets_CIDR_blocks = ["10.0.0.0/19", "10.0.32.0/19"]
public_subnets_CIDR_blocks  = ["10.0.64.0/19", "10.0.96.0/19"]
cluster_access_role_arn     = "arn:aws:iam::058264546862:role/regencrops-Admin-Role"
