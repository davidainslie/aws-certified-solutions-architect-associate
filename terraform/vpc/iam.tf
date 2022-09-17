# Create IAM Role where policy grants an EC2 instance to assume role
resource "aws_iam_role" "my-role" {
  name = "my-role"

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

  tags = {
    tag-key = "tag-value"
  }
}

# Create an EC2 instance profile
resource "aws_iam_instance_profile" "my-profile" {
  name = "my-profile"
  role = aws_iam_role.my-role.name
}

# Add IAM Policies which allows EC2 instance to execute specific commands for eg: access to S3 Bucket
resource "aws_iam_role_policy" "my-policy" {
  name = "my-policy"
  role = aws_iam_role.my-role.id

  policy = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }]
  }
  EOT
}

# Attach this role to EC2 instance - See ec2-private.tf
# Note, for the following, ACL has been disabled.
# SSH onto public instance and from there onto private instance and check s3 connection e.g.
# aws s3 ls

# Including the endpoint below should still work but instead access S3 directly instead of via internet:
resource "aws_vpc_endpoint" "s3-endpoint" {
  service_name = "com.amazonaws.${var.aws-region}.s3"
  vpc_id       = aws_vpc.vpc.id
}

# Associate route table with VPC endpoint:
resource "aws_vpc_endpoint_route_table_association" "s3-route-table-association" {
  route_table_id  = aws_route_table.rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-endpoint.id
}