variable "bucket_id" {
  description = "ID (name) of the S3 bucket to configure lifecycle rules for"
  type        = string
}

variable "lifecycle_rules" {
  description = "List of lifecycle rule configurations"
  type = list(object({
    id     = string
    status = optional(string, "Enabled")
    prefix = optional(string, null)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
    expiration_days                        = optional(number, null)
    noncurrent_version_expiration_days     = optional(number, null)
    abort_incomplete_multipart_upload_days = optional(number, null)
  }))
  default = [{
    id                                     = "abort-incomplete-multipart"
    status                                 = "Enabled"
    abort_incomplete_multipart_upload_days = 7
  }]
}
