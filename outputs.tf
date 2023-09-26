output "website_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.terrahouse_aws.wonder_bucket.arn
}

output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = module.terrahouse_aws.wonder_bucket.name
}

output "website_bucket_domain" {
  description = "Domain name of the bucket"
  value       = module.terrahouse_aws.wonder_bucket.domain
}