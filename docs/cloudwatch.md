# CloudWatch

CloudWatch is a `monitoring` and `observability` platform that was designed to give us insight into our AWS architecture.
It allows us to monitor multiple levels of our applications and `identity` potential issues.

CloudWatch features (what can CloudWatch do?):
- System metrics
  - CloudWatch can collect metrics that you get out of the box; the more managed the service is, the more you get, e.g. is the CPU/memory too high?
- Application metrics
  - By installing the CloudWatch agent, you can get information from inside your EC2 instance e.g. is my Apache process running?
- Alarms
  - This answers the question, what is the point of collecting metrics? The point is to then create alarms.
  - Alarms can alert you when something goes wrong.

2 kinds of metrics:
- Default
  - These metrics are provided out of the box, such as:
    - CPU utilisation
    - Network throughput
- Custom
  - These metrics will need to be provided by using the CloudWatch agent installed on the host, allowing for configuration of:
    - EC2 memory utilisation
    - EBS storage capacity

Take a look at the [terraform cloudwatch example](../terraform/cloudwatch/main.tf).