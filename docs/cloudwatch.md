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

## Application monitoring with CloudWatch Logs

How do we handle all our logs from EC2 instances, RDS, Lambda, CloudTrail etc?

CloudWatch Logs is a tool that allows you to `monitor`, `store` and `access` log files from a variety of different sources.
It gives you the ability to query your log to look for potential issues or data data is relevant to you.
Instead of just leaving log files on `hosts` (such as an EC2 instance) we can collect them onto a single centralised storage location.

- Log Event:
  - This is the record of what happened. It contains a `timestamp` and the `data`.
- Log Stream:
  - A collection of log events from the same source create a log stream. Think of one continuous set of logs from a single instance.
- Log Group:
  - This is a collection of log streams. E.g. you'd group all your Apache web server logs across hosts together.

What do we do with these collected logs?
- Filter patterns:
  - You can look for specific terms in your logs. Think 400 errors in your web server logs.
- CloudWatch Logs Insights:
  - This allows you to query all your logs using SQL-like interactive solution.
- Alarms:
  - Once you've identified your trends or patterns, it's time to alert on them.

In order to use CloudWatch Logs, we need to install the `CloudWatch Agent` on our EC2 instance - Again see the [terraform cloudwatch example](../terraform/cloudwatch/main.tf).

To (manually) install we have to run:
```shell
sudo yum install amazon-cloudwatch-agent -y

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
# And we are then prompted with some questions.
```

Using terraform, a slightly different approach is taken, again all shown in the [terraform cloudwatch example](../terraform/cloudwatch/main.tf), with the help of the artical [CloudWatch Agent on EC2 with Terraform](https://jazz-twk.medium.com/cloudwatch-agent-on-ec2-with-terraform-8cf58e8736de).

Monitoring tips:
- CloudWatch is the main tool for anything alarm related.
- Not everything should go through CloudWatch e.g. AWS standards should be watched by AWS Config.
- The standard metric (free) is delivered every 5 minutes, while detailed monitoring (extra cost) delivers data every 1 minute.
- Use CloudWatch Logs Insights to query your logs with a SQL-like syntax.
- As CloudWatch Logs is not a real-time logging service, use Kinesis for real-time logging.