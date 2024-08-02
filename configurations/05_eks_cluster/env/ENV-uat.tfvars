AppEnv                      = "uat"
kms_key_id                  = "arn:aws:kms:ap-south-1:058264546862:key/7eb27311-d58e-48e2-8ed2-6e02a1a9a95b"
create_vpc                  = true
vpc_cidr_block              = "10.1.0.0/16"
private_subnets_CIDR_blocks = ["10.1.0.0/19", "10.1.32.0/19"]
public_subnets_CIDR_blocks  = ["10.1.64.0/19", "10.1.96.0/19"]
cluster_access_role_arn     = "arn:aws:iam::058264546862:role/regencrops-Admin-Role"

