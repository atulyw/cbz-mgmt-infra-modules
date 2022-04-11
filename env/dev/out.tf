output "public_subnet" {
  value = module.vpc.public_subnets
}

output "target_group_arns" {
  value = module.alb.target_group_arns
}

# output "test" {
#   value = module.alb.test
# }