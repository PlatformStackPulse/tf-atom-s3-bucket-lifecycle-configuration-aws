output "enabled" {
  description = "Whether the module is enabled."
  value       = local.enabled
}

output "id" {
  description = "Bucket ID of the lifecycle configuration"
  value       = try(aws_s3_bucket_lifecycle_configuration.this[0].bucket, null)
}
