# Output the generated random string
output "random_bucket_name_string" {
  description = "random string generated for S3 bucket"
  value = random_string.random_bucket_name.result
}

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.wonder_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.wonder_bucket.id
}

output "domain" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.wonder_bucket.bucket_domain_name
}

output "random_uuid" {
  value = random_uuid.id.result
}