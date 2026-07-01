# -----------------------------------------------------------------------------
# Unit tests — tf-atom-s3-bucket-lifecycle-configuration-aws
#
# Uses a mocked AWS provider so no credentials or real API calls are needed.
# Assertions target plan-KNOWN values only (the tf-label id string, resource
# count, the `enabled` output, and input pass-throughs). Computed attributes
# such as the resource `id`/`arn` are UNKNOWN under a mock provider at plan
# time, so they are never asserted on.
# -----------------------------------------------------------------------------

mock_provider "aws" {}

variables {
  namespace = "eg"
  stage     = "test"
  name      = "thing"
  bucket_id = "eg-test-thing-bucket"
}

# When enabled (default), the lifecycle configuration resource is created and
# the tf-label context resolves the expected id.
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = module.this.id == "eg-test-thing"
    error_message = "tf-label id should be 'eg-test-thing' from namespace/stage/name"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Exactly one aws_s3_bucket_lifecycle_configuration should be created when enabled"
  }

  assert {
    condition     = output.enabled == true
    error_message = "enabled output should be true by default"
  }
}

# The bucket_id input is passed straight through to the resource.
run "passes_bucket_id_through" {
  command = plan

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].bucket == "eg-test-thing-bucket"
    error_message = "bucket should be set from var.bucket_id"
  }
}

# Custom lifecycle rules with transitions + expiration are wired into the resource.
run "supports_transition_rules" {
  command = plan

  variables {
    lifecycle_rules = [{
      id     = "archive-old-objects"
      status = "Enabled"
      prefix = "logs/"
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
    condition     = length(aws_s3_bucket_lifecycle_configuration.this[0].rule) == 1
    error_message = "Exactly one lifecycle rule should be configured"
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].id == "archive-old-objects"
    error_message = "Rule id should pass through from var.lifecycle_rules"
  }
}

# When disabled, no resource is created and the id output is null.
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "No resource should be created when enabled = false"
  }

  assert {
    condition     = output.id == null
    error_message = "id output should be null when disabled"
  }

  assert {
    condition     = output.enabled == false
    error_message = "enabled output should be false when disabled"
  }
}
