output "main_subnet_ids" {
  value = data.aws_subnet_ids.main_subnets.ids
}

output "staging_subnet_ids" {
  value = data.aws_subnet_ids.staging_subnets.ids
}

output "prod_subnet_ids" {
  value = data.aws_subnet_ids.prod_subnets.ids
}
