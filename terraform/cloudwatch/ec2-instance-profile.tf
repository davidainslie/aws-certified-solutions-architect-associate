locals {
  role-policy-arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-Role"
  path = "/"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "ec2-policy" {
  name = "ec2-inline-policy"
  role = aws_iam_role.ec2-role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource" : "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy_attachment" "ec2-role-policy-attachment" {
  count      = length(local.role-policy-arns)
  role       = aws_iam_role.ec2-role.name
  policy_arn = element(local.role-policy-arns, count.index)
}