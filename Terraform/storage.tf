# Create an S3 bucket
resource "aws_s3_bucket" "s3-storage" {
  bucket = "web-app-main-storage"
}

# Enable versioning
resource "aws_s3_bucket_versioning" "s3-versioning" {
  bucket = aws_s3_bucket.s3-storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access of S3
resource "aws_s3_bucket_public_access_block" "s3-block-public-access" {
  bucket = aws_s3_bucket.s3-storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Defining lifecycles for current objects
resource "aws_s3_bucket_lifecycle_configuration" "s3-lifecycles" {
  bucket = aws_s3_bucket.s3-storage.id

  rule {
    id = "current"
    status = "Enabled"

    filter { prefix = "current/" }
    expiration { days = 120 }

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }    
  }
}

# Defining lifecycles for non current objects in order to
# apply transition and expiration to versioned objects
resource "aws_s3_bucket_lifecycle_configuration" "s3-versioning-lifecycles" {
  bucket = aws_s3_bucket.s3-storage.id
  depends_on = [ aws_s3_bucket_versioning.s3-versioning ]

  rule {
    id = "non-current"
    status = "Enabled"

    filter { prefix = "non-current/" }
    noncurrent_version_expiration { noncurrent_days = 90 }
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class = "GLACIER"
    }
  }
}