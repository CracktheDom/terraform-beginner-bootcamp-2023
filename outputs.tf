output "wonder_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.terrahouse_aws.arn
}

output "wonder_bucket_name" {
  description = "Name (id) of the bucket"
  value       = module.terrahouse_aws.name
}

output "wonder_bucket_domain" {
  description = "Domain name of the bucket"
  value       = module.terrahouse_aws.website_url
}

output "random_name" {
  description = "Random generated name of the bucket"
  value       = module.terrahouse_aws.random_bucket_name_string
}

output "random_uuid" {
  description = "Randomly generated UUID used for tags"
  value       = module.terrahouse_aws.random_uuid
}