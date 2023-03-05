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
  bucket                  = aws_s3_bucket.s3-storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Define the bucket policy to deny all the operations that comes
# from outside the internal vpc
resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3-storage.id
  policy = data.aws_iam_policy_document.s3-bucket-policy-document.json
}

# Create a policy document to deny all requests that do not come from 
# a specific VPC endpoint. This policy disables console access
# to the specified bucket, because console requests don't originate 
# from the specified VPC endpoint.
data "aws_iam_policy_document" "s3-bucket-policy-document" {
  statement {
    sid = "S3BucketPolicy"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect  = "Deny"
    actions = ["*"]
    resources = [
      aws_s3_bucket.s3-storage.arn,
      "${aws_s3_bucket.s3-storage.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.s3-vpc-endpoint.id]
    }
  }
}