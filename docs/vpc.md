# Virtual Private Cloud (VPC) Networking

## Overview

Think of a [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html) as a virtual data centre in the cloud.
- Logically isolated part of AWS Cloud where you can define your own network.
- Complete control of virtual network, including your own IP address range, subnets, route tables and network gateways.
- Fully customisable network:
  - You can leverage multiple layers of security, including security groups and network access control lists, to help control access to Amazon EC2 instances in each subnet.
- 1 subnet is always in 1 Availability Zone, where a subnet is essentially a `virtual firewall`.

E.g. a typical 3 tier system:
```
+--------------------+     +-----------------------+       +-------------------+
|     Web            |     |      Application      |       |      Database     |
|                    |     |                       |       |                   |
|Public facing subnet|     | Private subnet        |       | Private subnet    |
|                    |     | Can only speak to     |       | Can only speak to |
+--------------------+     | web and database tiers|       | application tier  |
                           +-----------------------+       +-------------------+
```

Additionally, you can create a `hardware virtual private network` connection between your corporate data centre and your VPC and leverage the AWS Cloud as an extension of your corporate data centre.

## CIDR

How to [calculate the IP address ranges](https://cidr.xyz) e.g.

![CIDR](images/cidr.jpg)

As the number after the `slash` goes from say 2 to 28, the IP range count decreases as it marks how many bits to use after the say the first 2 there is 30 bits to use,
but after first 28, there is only 4 bits to use, which comes to a total count of 16 (IP addresses to use) i.e.

0 0 0 0
8 4 2 1 = 16

## Network diagram example

When setting up a VPC we have to choose our IP address range (refer to CIDR website):

![VPC](images/vpc.jpg)

So what can we do with a VPC?
- Launch instances
  - Launch instances into a subnet of our choosing
- Custom IP addresses
  - Assign custom IP address ranges in each subnet
- Route tables
  - Configure route tables between subnets
- Internet gateway
  - Create internet gateway and attach it to our VPC
- More control
  - Much better security control over our AWS resources
- Access control lists
  - Subnet network access control lists
  - And we can use network access control lists (NACLs) to block specific IP addresses

Default VPC vs custom VPC:
- Default
  - Default VPC is user friendly
  - All subnets in default VPC have a route out to the internet
  - Each EC2 instance has both a public and private IP address
- Custom
  - Fully customisable
  - Takes time to set up

We can build a VPC in the UI or with [terraform (an example)](../terraform/vpc/main.tf).

When creating a VPC, by default it creates:
- main route table
- main network ACL
- security group

## NAT Gateways for internet access (for EC2 instances in a private subnet)

The terraform example includes the following:
You can use a network address translation (NAT) gateway to enable instances in a private subnet to connect to the internet or other AWS services while preventing the internet from initiating a connection with those instances.

So how does the private subnet get access `out`? The solution is to provision a NAT gateway in our public subnet. We'll essentially end up with:
![NAT gateway](images/nat-gateway.jpg)

- NAT gateways are redundant inside the Availability Zone
- Starts at 5Gbps and scales currently to 45Gbps
- Not associated with security groups
- Automatically assigned a public IP address