#! /bin/bash
set -e

# Ouput all log to the specified location
exec > >(tee /var/log/user-data.log | logger -t user-data-extra -s 2>/dev/console) 2>&1

# Make sure we have all the latest updates when we launch this instance
yum update -y
yum upgrade -y

# Configure Cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Use cloudwatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c ssm:${ssm-cloudwatch-config} -s

# Install Apache http and configure
sudo yum install httpd -y
sudo systemctl start httpd
echo "<html><body><h1><center>Simple server set up with Terraform Provisioner</center></h1></body></html>" > index.html
sudo mv index.html /var/www/html/

echo "Done initialization"