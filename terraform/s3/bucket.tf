resource "aws_s3_bucket" "s3-bucket" {
  bucket_prefix = "my-bucket-"

  force_destroy = true

  tags = {
    Name = "my-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-bucket-access" {
  bucket = aws_s3_bucket.s3-bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3-bucket-versioning" {
  bucket = aws_s3_bucket.s3-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "terraform-state-aws-s3-bucket" {
  value = aws_s3_bucket.s3-bucket.bucket
}