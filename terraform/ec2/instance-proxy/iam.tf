data "aws_iam_policy" "s3-full-access-policy" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_user" "my-user" {
  name = "my-user"
  path = "/"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "my-user-s3-policy-attachment" {
  user       = aws_iam_user.my-user.name
  policy_arn = data.aws_iam_policy.s3-full-access-policy.arn
}

resource "aws_iam_user" "s3-user" {
  name = "s3-user"
  path = "/"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "s3-user-policy-attachment" {
  user       = aws_iam_user.s3-user.name
  policy_arn = data.aws_iam_policy.s3-full-access-policy.arn
}

output "iam_user_name" {
  description = "The user's name"
  value       = try(aws_iam_user.s3-user.name, "")
}

resource "aws_iam_access_key" "s3-user-access-key" {
  user = aws_iam_user.s3-user.name
}

output "iam_access_key_id" {
  description = "The access key ID"
  value       = try(aws_iam_access_key.s3-user-access-key.id, "")
}

output "iam_access_key_secret" {
  description = "The access key secret"
  value       = nonsensitive(try(aws_iam_access_key.s3-user-access-key.secret, ""))
}