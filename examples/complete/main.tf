provider "aws" {
  region = "eu-west-2"
}

module "s3_lifecycle" {
  source = "../../"

  namespace   = "psp"
  environment = "dev"
  name        = "assets"

  bucket_id = "psp-dev-assets"

  lifecycle_rules = [
    {
      id = "transition-to-ia"
      transitions = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
    },
    {
      id              = "expire-old"
      expiration_days = 365
    },
    {
      id                                     = "cleanup-multipart"
      abort_incomplete_multipart_upload_days = 7
    }
  ]
}

output "id" {
  value = module.s3_lifecycle.id
}
