resource "aws_s3_bucket" "s3-source-bucket" {
  bucket_prefix = "source-bucket-"
  force_destroy = true

  tags = {
    Name = "source-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3-source-bucket-versioning" {
  bucket = aws_s3_bucket.s3-source-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "s3-source-bucket-policy" {
  bucket = aws_s3_bucket.s3-source-bucket.id

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
          "arn:aws:s3:::${aws_s3_bucket.s3-source-bucket.bucket}/*"
        ]
      }]
    }
  EOT
}

resource "aws_s3_object" "s3-bucket-source-files" {
  depends_on = [aws_s3_bucket.s3-source-bucket, aws_s3_bucket.s3-replication-bucket]
  for_each = fileset(".", "*.jpg")
  bucket = aws_s3_bucket.s3-source-bucket.bucket
  key = each.value
  source = "./${each.value}"
  content_type = "image/jpeg"
}

output "s3-source-bucket" {
  value = aws_s3_bucket.s3-source-bucket.bucket
}