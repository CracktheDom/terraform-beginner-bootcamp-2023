# Output the generated random string
output "random_bucket_name_string" {
  description = "random string generated for S3 bucket"
  value       = random_string.random_bucket_name.result
}

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.wonder_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.wonder_bucket.id
}

output "website_url" {
  description = "URL of the bucket"
  value       = aws_s3_bucket_website_configuration.wonder_bucket_config.website_endpoint
}

output "random_uuid" {
  value = random_uuid.id.result
}