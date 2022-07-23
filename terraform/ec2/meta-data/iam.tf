data "aws_iam_policy" "s3-full-access-policy" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"

  assume_role_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }]
    }
  EOT
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy_attachment" "s3-full-access-policy-attach" {
  role = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.s3-full-access-policy.arn
}