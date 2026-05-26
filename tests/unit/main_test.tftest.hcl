mock_provider "aws" {}

run "creates_lifecycle_with_defaults" {
  variables {
    name        = "test"
    environment = "dev"
    namespace   = "unit"
    bucket_id   = "my-test-bucket"
  }

  assert {
    condition     = output.id != null
    error_message = "id output should not be null when enabled"
  }
}

run "creates_nothing_when_disabled" {
  variables {
    name        = "test"
    environment = "dev"
    namespace   = "unit"
    enabled     = false
    bucket_id   = "my-test-bucket"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "No resource should be created when disabled"
  }
}

run "supports_transition_rules" {
  variables {
    name        = "test"
    environment = "dev"
    namespace   = "unit"
    bucket_id   = "my-test-bucket"
    lifecycle_rules = [{
      id     = "archive-old-objects"
      status = "Enabled"
      transitions = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }, {
        days          = 90
        storage_class = "GLACIER"
      }]
      expiration_days = 365
    }]
  }

  assert {
    condition     = output.id != null
    error_message = "Should create lifecycle config with transitions"
  }
}
