resource "aws_s3_bucket" "s3-replication-bucket" {
  bucket_prefix = "replication-bucket-"
  force_destroy = true

  tags = {
    Name = "replication-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3-replication-bucket-versioning" {
  bucket = aws_s3_bucket.s3-replication-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication-iam-role" {
  name = "replication-iam-role"

  assume_role_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole"
        ]
      }]
    }
  EOT
}

resource "aws_s3_bucket_policy" "s3-replication-bucket-policy" {
  bucket = aws_s3_bucket.s3-replication-bucket.id

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
          "arn:aws:s3:::${aws_s3_bucket.s3-replication-bucket.bucket}/*"
        ]
      }]
    }
  EOT
}

resource "aws_s3_bucket_replication_configuration" "s3-replication-configuration" {
  depends_on = [aws_s3_bucket_versioning.s3-source-bucket-versioning, aws_s3_object.s3-bucket-source-files]
  role   = aws_iam_role.replication-iam-role.arn
  bucket = aws_s3_bucket.s3-source-bucket.id

  rule {
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.s3-replication-bucket.arn
    }
  }
}

resource "aws_iam_policy" "replication-iam-policy" {
  name = "replication-iam-policy"

  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.s3-source-bucket.arn}"
        ]
      }, {
        "Effect": "Allow",
        "Action": [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        "Resource": [
          "${aws_s3_bucket.s3-source-bucket.arn}"
        ]
      }, {
        "Effect": "Allow",
        "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        "Resource": [
          "${aws_s3_bucket.s3-replication-bucket.arn}/*"
        ]
      }]
    }
  EOT
}

resource "aws_iam_role_policy_attachment" "iam-role-policy-attachment" {
  policy_arn = aws_iam_policy.replication-iam-policy.arn
  role       = aws_iam_role.replication-iam-role.name
}

output "s3-replication-bucket" {
  value = aws_s3_bucket.s3-replication-bucket.bucket
}