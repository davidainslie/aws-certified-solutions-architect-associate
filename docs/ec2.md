# EC2 - Elastic Compute Cloud

EC2 is:
- Secure, resizable compute capacity in the cloud
- Like a VM, only hosted in AWS instead of your own data centre

> Applications that run on an EC2 instance must include AWS credentials in their AWS API requests.
> You could have Developers store AWS credentials directly within the EC2 instance to allow applications in that instance to use those credentials.
> However, Developers would then have to manage those credentials and ensure that they securely pass the credentials to each instance and update each instance when it's time to rotate the credentials.
> A better (and the recommended way) is to use Roles.
> Roles are entities that define a set of permissions for making AWS service requests.
> You can think of an IAM role for EC2 as what you can do.
> But you can associate a role directly with an EC2 instance where you need an instance profile to do so.
> An instance profile is an entity or a container that's used for connecting an IAM role to an EC2 instance.
> So think of an instance profile as "who am I?".
> i.e. the role is what can I do? And the instance profile is who am I?
> Instance profiles provide temporary credentials, which are rotated automatically.
> So, if a hacker gets into your server, and get the credentials, but those credentials only live for a short period of time.
> When you create and attach the role to an EC2 instance in the AWS management console, the creation and use of the instance profile is actually handled behind the scenes.

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
  - Use spot instances for stateless, fault-tolerant or flexible applications:
    - Applications such as big data
    - containerised workloads
    - CI/CD
    - high performance computing (HPC)
    - and other test and development workloads
  - You must first chose a `maximum spot price` e.g. $1 an hour - If spot prices go above this, you have `2 minutes` to choose whether to stop of terminate your instance.
  - You can use `spot block` to avoid your spot instance being terminated (when price is above your maximum) for between 1 to 6 hours.
  - Services you DONT want to run on spot instances:
    - Persistent workloads
    - Critical jobs
    - Databases
  - In order to run spot instances, you issue a `spot request` which contains the likes of `maximum price` and `number of instances required`.
  - And you cannot just stop instances, you will have to first issue a `cancel request`.
  - You can also issue a `spot fleet request` (a collection of spot instances and optionally on-demand instances), which will try and match the target capacity with your price restraints.
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

Let's go through an example with aid of some `MUCH IMPROVED` [terraform](../terraform/ec2/roles/main.tf):
- Create a S3 bucket.
- Create an IAM Role: Ensure it has S3 access.
- Create an EC2 instance: Attach the Role that was created.
- Access S3: Try to access S3 from our EC2 instance.

What you should conclude from this example (compared to the previous):
- Preferred option
  - Roles are preferred from a security perspective
- Avoid hard coding your credentials
  - Roles allow you to provide access without the use of access key ID and secret access key
- Policies
  - Policies control a role's permissions
- Updates
  - You can update a policy attached to a role, and it will take immediate effect
- Attaching and detaching
  - You can attach and detach roles to running EC2 instances without having to stop or terminate those instances

Terraform is best, but here is an example of using the AWS CLI with regards to roles:
```shell
# Create a trust policy - This is a policy that allows an EC2 service to assume a role.
# Remember, with terraform we created:
# resource "aws_iam_role" "ec2-role" {
#   name = "ec2-role"
# 
#   # Trust policy
#   assume_role_policy = <<-EOT
#     {
#       "Version": "2012-10-17",
#       "Statement": [{
#         "Action": "sts:AssumeRole",

# We can do this from the CLI by creating a JSON file e.g.
vi trust-policy.json

# In vi:
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Effect": "Allow"
  }]
}

# Create role:
aws iam create-role --role-name DEV_ROLE --assume-role-policy-document file://trust-policy.json
# where assume-role-policy-document equates to terraform assume_role_policy

# Grant the role read access to one of our S3 buckets - Create an IAM policy that defines those permissions.
# In terraform we just used the AWS managed policy "AmazonS3FullAccess". Here, create and edit:
vi dev-read-access.json

# In vi:
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowUserToSeeBucketListInTheConsole",
    "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
    "Effect": "Allow",
    "Resource": ["arn:aws:s3:::*"]
  }, {
    "Effect": "Allow",
    "Action": ["s3:Get*", "s3:List*"],
    "Resource": [
      "arn:aws:s3:::dev-bucket/*",
      "arn:aws:s3:::dev-bucket"
    ]
  }]
}

# Create an IAM policy referencing this policy document (in terraform we just did: data "aws_iam_policy"):
aws iam create-policy --policy-name DevS3ReadAccess --policy-document file://dev-read-access.json

# The output of the last command includes an ARN to be used e.g.
"Arn": "arn:aws:iam:56893456:policy/DevS3ReadAccess"

# Create an instance profile (in order to associate the policy with the role). So just like terraform "aws_iam_role_policy_attachment":
aws iam attach-role-policy --role-name DEV_ROLE --policy-arn "arn:aws:iam:56893456:policy/DevS3ReadAccess"

aws iam list-attached-role-policies --role-name DEV_ROLE

# So create the instance profile:
aws iam create-instance-profile --instance-profile-name DEV_PROFILE

# And add role to the instance profile:
aws iam add-role-to-instance-profile --instance-profile-name DEV_PROFILE --role-name DEV_ROLE

aws iam get-instance-profile --instance-profile-name DEV_PROFILE

# Associate the IAM instance profile with the EC2 instance ID:
aws ec2 associate-iam-instance-profile --instance-id i-08945623d7e92b --iam-instance-profile Name="DEV_PROFILE"

aws ec2 describe-instances --instance-ids i-08945623d7e92b

# We could now ssh onto the EC2 instance to see that indeed it has assumed the role e.g.
ssh ec2_user@3.238.91.90

# and issue the command to the secure token service:
aws sts get-caller-identity
{
  "Account": "56893456",
  "UserId": "ADSFSATEASAFDASFDSDFGSAD:i-08945623d7e92b",
  "Arn": "arn:aws:sts::56893456:assumed-role/DEV_ROLE/i-08945623d7e92b"
}
```

## Security Groups and bootstrap scripts

How computer communicate?
- Linux: SSH on port 22
- Windows: RDP on port 3389
- HTTP: Web browsing on port 80
- HTTPS: Encrypted web browsing (SSL) on port 443

Security Groups:
- These are virtual firewalls for your EC2 instance, and by default, everything is blocked i.e. don't give SG to EC2 then even you can't access it.
- To let everything in use `0.0.0.0/0`, with the necessary port(s)

Bootstrap script:
- A script that runs when the instance first runs

## EC2 Metadata and User Data

What is EC2 metadata?
- It is data about your EC2 instance
  - Includes information such as `private IP address`, `public IP address`, `hostname`, `security groups` etc.
- Using `curl`, we can query metadata about our EC2 instance, e.g. we could make a call as part of the `user data` and save to a file for say `local-ipv4`:
  - ```shell
    #!/bin/bash
    curl http://169.252.169.254/latest/meta-data/local-ipv4 > myIP.txt
    ```
    
Take a look at the [terraform](../terraform/ec2/meta-data/main.tf) which uses the previous terraform as a template, but we also output the EC2 IP in `index.html`.

## Networking with EC2

You can attach 3 different types of `virtual networking cards` to your EC2 instances:
- ENI: Elastic Network Interface (simply a virtual network card - the default attached to an EC2 instance)
  - For basic day-to-day networking
  - Private IPv4 addresses
  - Public IPv4 addresses
  - Many IPv6 addresses
  - MAC address
  - 1 or more security groups
  - Common use cases:
    - Create a management network
    - Use network and security applicances in your VPC
    - Create dual-homed instances with workloads/roles on distinct subnets
    - Create a low-budget high availability solution
- EN: Enhanced Networking (for high performance networking between 10 to 100 Gbps)
  - Uses single root I/O virtualisation (SR-IOV) to provide high I/O performance and lower CPU utilisation
  - Provides higher bandwidth, higher packet per second (PPS) performance, and consistently lower inter-instance latencies
  - Comes in 2 flavours:
    - ENA: Elastic Network Adapter, supports network speeds up to 100 Gbps
    - VF: Intel 82599 Virtual Function Interface, support up to 10 Gbps (typically used on older instances)
- EFA: Elastic Fabric Adapter
  - Accelerates High Performance Computing (HPC) and machine learning applications
  - Provides lower and more consistent latency and higher throughput than the TCP transport traditionally used in cloud-based HPC systems
  - Can use OS-bypass to be even faster with much lower latency, where applications can bypass the operating system kernel, on Linux, and communicate directly with the EFA device

## Optimising with EC2 placement groups

There are 3 types of placement groups:
- Cluster
  - Grouping of instances within a single Availability Zone.
  - Recommended for applications that need low network latency, high throughput, or both.
  - Only certain instance types can be launched into a cluster placement group.
- Spread
  - A group of instances that are each placed on distinct underlying hardware.
  - Recommended for applications that have a small number of critical instances that should be kept separate from each other.
- Partition
  - Each partition placement group has its own set of racks, its own network and power source.

## Timeing workloads with spot instances and spot fleets

Take a look at the [terraform](../terraform/ec2/spot/main.tf).