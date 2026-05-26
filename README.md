# tf-atom-s3-bucket-lifecycle-configuration-aws

[![CI](https://github.com/PlatformStackPulse/tf-atom-s3-bucket-lifecycle-configuration-aws/actions/workflows/ci.yml/badge.svg)](https://github.com/PlatformStackPulse/tf-atom-s3-bucket-lifecycle-configuration-aws/actions/workflows/ci.yml)
[![Release](https://github.com/PlatformStackPulse/tf-atom-s3-bucket-lifecycle-configuration-aws/actions/workflows/auto-release.yml/badge.svg)](https://github.com/PlatformStackPulse/tf-atom-s3-bucket-lifecycle-configuration-aws/actions/workflows/auto-release.yml)

---

## Purpose

Configures object lifecycle rules for an S3 bucket, enabling automatic transitions between storage classes, object expiration, and cleanup of incomplete multipart uploads. Essential for cost optimization.

## Architecture

```
┌───────────────────────────────────────────────────────────┐
│           Molecule Layer                                  │
│  ┌──────────────┐    ┌────────────────────────────┐      │
│  │ s3-bucket    │───▶│ THIS MODULE                │      │
│  │ (bucket_id)  │    │ lifecycle-configuration    │      │
│  └──────────────┘    │ (transitions/expiration)   │      │
│                      └────────────────────────────┘      │
│  Storage classes: STANDARD → STANDARD_IA → GLACIER       │
└───────────────────────────────────────────────────────────┘
```

## Scope

| In Scope | Out of Scope |
|----------|--------------|
| `aws_s3_bucket_lifecycle_configuration` resource | Bucket creation (→ `tf-atom-s3-bucket-aws`) |
| Storage class transitions | Versioning (→ `tf-atom-s3-bucket-versioning-aws`) |
| Object expiration | Replication rules |
| Noncurrent version handling | Intelligent tiering |
| Multipart upload cleanup | Object lock retention |

## Features

- **Single-resource atom** — one `aws_s3_bucket_lifecycle_configuration`
- **Multiple rules** — supports any number of lifecycle rules
- **Storage transitions** — STANDARD_IA, ONEZONE_IA, GLACIER, DEEP_ARCHIVE
- **Noncurrent versions** — separate handling for versioned objects
- **Multipart cleanup** — aborts incomplete uploads (default: 7 days)
- **Tested** — unit tests for defaults, disabled, and transition rules

## Usage

```hcl
module "bucket_lifecycle" {
  source = "github.com/PlatformStackPulse/tf-atom-s3-bucket-lifecycle-configuration-aws?ref=v1.0.0"

  context   = module.this.context
  bucket_id = module.bucket.bucket_id

  lifecycle_rules = [{
    id = "archive-and-expire"
    transitions = [{
      days          = 90
      storage_class = "GLACIER"
    }]
    expiration_days = 365
  }]
}
```

## Module Documentation

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
