resource "aws_s3_bucket" "s3-website-bucket" {
  bucket_prefix = "my-bucket-"
  force_destroy = true

  tags = {
    Name = "my-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-website-bucket-access" {
  bucket = aws_s3_bucket.s3-website-bucket.id

  # Static website that has public access
  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "s3-website-bucket-versioning" {
  bucket = aws_s3_bucket.s3-website-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "s3-website-bucket-policy" {
  bucket = aws_s3_bucket.s3-website-bucket.id

  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.s3-website-bucket.bucket}/*"
        ]
      }]
    }
  EOT
}

resource "aws_s3_bucket_website_configuration" "s3-website-configuration" {
  bucket = aws_s3_bucket.s3-website-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "s3-bucket-website-files" {
  for_each = fileset(".", "*.html")
  bucket = aws_s3_bucket.s3-website-bucket.bucket
  key = each.value
  source = "./${each.value}"
  content_type = "text/html"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-website-bucket-lifecycle-rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3-website-bucket-versioning]

  bucket = aws_s3_bucket.s3-website-bucket.bucket

  rule {
    id = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 120
    }
  }
}

output "s3-website-bucket" {
  value = aws_s3_bucket.s3-website-bucket.bucket
}

output "s3-website-endpoint" {
  value = aws_s3_bucket_website_configuration.s3-website-configuration.website_endpoint
}