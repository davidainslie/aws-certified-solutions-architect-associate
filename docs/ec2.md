# EC2 - Elastic Compute Cloud

EC2 is:
- Secure, resizable compute capacity in the cloud
- Like a VM, only hosted in AWS instead of your own data centre

## Pricing options

There is an [AWS pricing calculator](https://calculator.aws/#/).

- On-demand
  - Pay by the hour or the second, depending on the type of instance you run.
  - Flexible: Low cost and flexibility of Amazon EC2 without any upfront payment or long-term commitment.
  - Short-term: Applications with short-term, spiky, or unpredictable workloads that cannot be interrupted.
  - Testing the water: Applications being developed or tested on Amazon EC2 for the first time.
- Reserved
  - Reserved capacity for 1 or 3 years - Up to 72% discount on the hourly charge.
  - Predictable usage: Applications with steady state or predictable usage.
  - Specific capacity requirements: Applications that require reserved capacity.
  - Pay up front: You can make up front payments to reduce the toal computing costs even further.
  - Reserved instanced operate at a `regional level`.
  - Standard reserved instances (RIs) for up to 72% off the on-demand price.
  - Convertible reserved instances (RIs) for up to 54% off the on-demand price - Has the option to change to a different RI type of equal or greater value.
  - Scheduled reserved instances (RIs): Launch within the time window you define. Match your capacity reservation to a predictable recurring schedule that only required a fraction of a day, week or month.
  - Reserved instances are not just for EC2, but also serverless technologies such as Lambda and Fargate.
- Spot
  - Purchase unused capacity at a discount of up to 90% - Prices fluctuate with supply and demand.
  - Applications that have flexible start and end times.
  - Applications that are only feasible at very low compute prices.
  - Users with an urgent need for large amounts of additional computing capacity - some usages/applications such as:
    - Image rendering
    - Genomic sequencing
    - Algorithmic trading engines
- Dedicated
  - A physical EC2 server dedicated for your use - The most expensive option.
  - Compliance: Regulatory requirements that may not support multi-tenant virtualisation i.e. where underlying hardware is shared with other AWS customers which we can't have due to compliance.
  - Licensing: Great for licensing that does not support multi-tenancy or cloud deployments.
  - On-demand: Can be purchased on-demand (hourly).
  - Reserved: Can be purchased as a reservation for up to 70% off the on-demand price.

## An EC2 instance

- Think of a VPC as your data centre, which is in a region.
- Think of each subnet as an availability zone e.g. you will probably have a minimum of 3 available, so you may launch 3 EC2 instances within a region.
- Security group is a virtual firewall in the cloud - allows traffic in/out of your EC2 instance.
- Upon launching an EC2 instance (from the console) you will be given the opportunity to create or reuse a key/pair where the private key is used in conjunction with SSH.
  - When you ssh (using the pem) you can switch to `root` using `sudo su`.

## Command line

Let's go through an example with the aid of some [terraform](../terraform/ec2/instance-proxy/main.tf):
- Launch an EC2 instance - this is where we will use AWS CLI.
- Create an IAM user - giving the user permissions to access and create S3 resources.
- Configure the AWS CLI using the IAM user's credentials - use the CLI to create a S3 bucket and upload a file.

## Using Roles

What is an IAM Role?
> A Role is an identity you can create in IAM that has specific permissions.
> A Role is similar to a user, as it is an AWS identity with permission policies that determine what the identity can and cannot do in AWS.
> However, instead of being uniquely associated with one person, a role is intended to be assumable by anyone who needs it.

Roles are temporary:
> A Role does not have standard long-term credentials the same way passwords or access keys do.
> Instead, when you assume a role, it provides you with temporary security credentials for your role session.

What else can Roles do?
> Roles can be assumed by people, AWS architecture, or other system-level accounts.
> Roles can allow cross-account access - This gives one AWS account the ability to interact with resources in other AWS accounts.

Let's go through an example with aid of some [terraform](../terraform/ec2/roles/main.tf):
- Create a S3 bucket.
- Create an IAM Role: Ensure it has S3 access.
- Create an EC2 instance: Attach the Role that was created.
- Access S3: Try to access S3 from our EC2 instance.