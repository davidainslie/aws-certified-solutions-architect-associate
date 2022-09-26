# Get all available AZ's in VPC for master region
# us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f
data "aws_availability_zones" "azs" {
  state = "available"
}