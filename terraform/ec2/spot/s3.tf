resource "aws_s3_bucket" "s3-bucket" {
  bucket_prefix = "s3-bucket-"
  force_destroy = true

  tags = {
    Name = "s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3-bucket-versioning" {
  bucket = aws_s3_bucket.s3-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3-bucket.id

  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.s3-bucket.bucket}/*"
        ]
      },{
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.s3-bucket.bucket}"
        ]
      }]
    }
  EOT
}

resource "aws_s3_bucket_public_access_block" "s3-bucket-access" {
  depends_on = [aws_s3_bucket_policy.s3-bucket-policy]
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "s3-bucket-files" {
  bucket = aws_s3_bucket.s3-bucket.bucket
  for_each = fileset(".", "*.jpg")
  key = each.value
  source = "./${each.value}"
  content_type = "image/jpeg"
}

output "s3-bucket" {
  value = aws_s3_bucket.s3-bucket.bucket
}