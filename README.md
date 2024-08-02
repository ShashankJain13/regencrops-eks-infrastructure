Task to do before moving to new account

1. Create VPC , subnet and security group
2. Change resource groups from example to regencrops-eks
3. rename module name in alb_ingress_controller_service_account  from service accout to alb-service-account
4. Attach CW Agent policy - aws iam attach-role-policy --role-name my-worker-node-role  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy --profile prod