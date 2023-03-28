# Automation

## CloudFormation

1. Write code:
   1. CloudFormation is a declarative programming language; it supports either JSON or YAML formatting.
2. Deploy your template:
   2. When you upload your template, CloudFormation will go through the process of making the needed AWS API calls on your behalf.

## Elastic Beanstalk

PaaS:
- Platform as a Service, is a single-stop application deployment model.
- You bring your code, and the provider builds everything for you; deploys your application; then manages it going forward.

Elastic Beanstalk (the Amazon PaaS tool):
- Automation:
  - Elastic Beanstalk automates all your deployments; you can template what you would like your environment to look like.
- Deployment:
  - It will handle all your deployments; you upload your code; test your code in a staging environment; then deploy to production.
- Management:
  - It will handle building out the insides of your EC2 isntances.
- Supports containers (i.e. Docker, though normally you'd use ECS or EKS), Windows and Linux applications.
- It's not serverless - Beanstalk is creating and managing standard EC2 architecture.

## Systems Manager

Systems Manager is a suite of tools designed to let you view, control, and automate both your AWS architecture and on-premises resources.

- Automation documents (also called Runbooks):
  - Can be used to control your instances or AWS resources.
- Run command:
  - Execute commands on your hosts; Run command uses the Systems Manager agent installed on your EC2 instance, to do things; unlike ssh onto each instance to say run a script to install something on an EC2 instance, you can instead use Run command just once for all instances.
- Path manager:
  - Manages your application versions.
- Parameter store:
  - Securely store your secret values.
- Hybrid activations:
  - Control your on-premises architecture using Systems Manager (and just like EC2 instances, will need Systems Manager agent installed).
- Session Manager:
  - Remotely connect and interact (through your browser) with your architecture (so you don't have to manage ssh keys).