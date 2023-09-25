# Output the generated random string
output "random_bucket_name_string" {
  value = random_string.random_bucket_name.result
}
