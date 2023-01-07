# Serverless Architecture

A short history of how things used to be and what we have now i.e. serverless:
- First there were physical data centres:
  - A long time ago, we put computers in a giant warehouse and called it a `data centre`.
- Next we had virtualisation:
  - We started to virtualise computers; computers running more computers inside of them.
- Then along came `the cloud`:
  - Running physical hardware is holding us back, so we now manage virtual compute.
- And finally `serverless`:
  - We focus on code and leave the management of the compute architecture behind.

## Computing with Lambda

AWS Lambda is a serverless compute service that lets you run code without provisioning or managing the underlying servers.
It's as if you are running code without computers.

- Runtime:
  - You'll need to pick from an available runtime or bring your own; this is the environment your code will run in.
- Permissions:
  - If your lambda function needs to make an AWS API call, you'll need to attach a role.
- Networking:
  - You can (optionally) define the VPC, subnet, and security groups your functions are a part of.
- Resources:
  - Defining the amount of available memory will allocate how much CPU and RAM your code gets.
- Trigger:
  - What's going to alert your lambda function to start? Defining a trigger will kick lambda off if that event occurs.

One of the most common ways you're going to see lambda used is to `add features to AWS`.

If you need to automatically remove entries from a security group, start and stop instances, or do anything else that isn't built in, `the answer is most likely going to be to use lambda to achieve that`.

## Leveraging the AWS Serverless Application Repository

- Serverless apps:
  - Allows users to easily find, deploy, or even publish their own serverless applications.
- Sharing:
  - Ability to privately share applications within orgs or publicly for the world.
- Manifest:
  - Upload your application code and a manifest file; known as the AWS SAM (Serverless Application Model) template.
- Integrations:
  - Deeply integrated with the AWS lambda service; appears within the console.

| Publish (vs)                                                       | Deploy                                            |
|--------------------------------------------------------------------|---------------------------------------------------|
| Publishing apps makes them available for others to find and deploy | Find and deploy published applications            |
| Define apps with AWS SAM templates                                 | Browse public apps without needing an AWS account |
| Set to private by default                                          | Browse within the AWS lambda console              |
| Must explicitly share if desired                                   |                                                   |

## Container overview

What is a Container?
- A container is a standard unit of software that `packages` up code and all its dependencies, so the application runs quickly and reliably from `one computing environment to another`.

![Virtual machines vs Containers](images/virtual-machine-vs-container.jpg)

- Dockerfile
  - Text document that contains all the commands or instructions that will be used to build an image.
- Image
  - Immutable file that contains the code, libraries, dependencies, and configuration files needed to run an application.
- Registry
  - Stores Docker images for distribution; can be both private and public.
- Container
  - A running copy of the image that has been created.

## Running Containers in ECS (Elastic Container Service) or EKS (Elastic Kubernetes Service)

Having a handful of containers is fine, but when we get into the 10s and 100s we need help to manage all our containers. Enter ECS:
- Management of containers at scale:
  - ECS can manage 1, 10, hundreds, thousands of containers; it will appropriately place the containers and keep them online.
- ELB integration:
  - Containers are appropriately registered with the load balancers as they come online and go offline.
- Role integration:
  - Containers can have individual roles attached to them, making security a breeze.

One downside of ECS, is that is propriety to AWS. To avoid this `tie-in` we can instead opt for Kubernetes.

Kubernetes is an open-source container management and orchestration platform:
- Open source alternative
- Can be used on-premises and in the cloud

Kubernetes itself can be pretty hard to configure/manage, and that is where EKS can help.
EKS is an AWS-managed version of Kubernetes.

We have a full [Node ECS example](../terraform/ecs-node/main.tf) of a Node app that is dockerised; pushed to ECR; spin up ECS; include a load balancer; and deploy.
This was just me following the blog [How to Deploy a Dockerised Application on AWS ECS with Terraform](https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785).

Following the above, we have a similar example with [Scala exposing a http4s API](../terraform/ecs-scala/build.sbt).

We go into more details in the [docker readme](docker.md).

ECS has three parts: clusters, services, and tasks.
- Tasks are JSON files that describe how a container should be run e.g. you need to specify the ports and image location for your application.
- A service simply runs a specified number of tasks and restarts/kills them as neededl this has similarities to an auto-scaling group for EC2.
- A cluster is a logical grouping of services and tasks.

## Removing servers with Fargate

Fargate is a serverless compute engine for containers that works with both Elastic Container Service (ECS) and Elastic Kubernetes Service (EKS).
So when using Fargate, you have to chose whether to depend on ECS or EKS.

| EC2                                                 | Fargate                                                                           |
|-----------------------------------------------------|-----------------------------------------------------------------------------------|
| You are responsible for underlying operating system | No operating system access                                                        |
| EC2 pricing model                                   | Pay based on resources allocated and time run - Generally more expensive than EC2 |
| Long-running containers                             | Short-running tasks                                                               |
| Multiple containers share the same host             | Isolated environments                                                             |

| Fargate                                                                  | Lambda                                                              |
|--------------------------------------------------------------------------|---------------------------------------------------------------------|
| Select Fargate when you have consistent workloads                        | Greate for unpredictable or inconsistent workloads                  |
| Allows Docker use across the organisation and a greater level of control | Perfect for applications that can be expressed as a single function |
|                                                                          | Time-contraint                                                      |

Summary:

Lambda: short running; well defined ---> Fargate: more complex container that don't need to run all the time ---> EC2: full blown apps running potentially 24/7

## Amazon EventBridge (CloudWatch Events)

Amazon EventBridge (formly known as CloudWatch Events) is a serverless event bus.
It allows you to pass events from a source to an endpoint.
Essentially, it's the glue that holds your serverless application together.
E.g. a common use case is triggering Lambda functions when an AWS API call happens.

Creating a rule:
- Define pattern:
  - Do you want the rule to be invoked based on an event happening? Or do you want this to be scheduled?
- Select event bus:
  - Is this going to be an AWS-based event? A custom event? Or a partner?
- Select your target:
  - What happens when this event kicks off? Do you trigger a Lambda function? Post to a SQS queue? Send an email?
- Tag:
  - You should/need to tag everything.
- Sit back:
  - Wait for the event to happen - Or kick it off yourself to make sure it's working correctly.

## Storing custom Docker images in Amazon Elastic Container Registry (ECR)

ECR:
- An AWS managed container image registry that offers secure, scalable, and reliable infrastructure.
- Private container image repositories with resource-based permissions via IAM.
- Supports Open Container Initiative (OCI) images, Docker images, and OCI artifacts.

Lifecycle policies:
- Helps management of images in your repositories.
- Defines rules for cleaning up unused images.
- Ability to test your rules before applying them.

Image scanning:
- Help identity software vulnerabilites in your container images.
- Repositories can be set to scan on push.
- Retrieve results of scana for each image.

Sharing:
- Cross-region support.
- Cross-account support.
- Configured per repository and per region.

Tag mutability:
- Prevents image tags from being overwritten.
- Configured per repository.

## Open source Kubernets in Amazon EKS Distro

- EKS-D:
  - Amazon EKS Distro (EKD-D) is a Kubernetes distribution based on and used by Amazon EKS.
- Similarities:
  - It has the same versions and dependencies deployed by Amazon EKS.
- Differences:
  - EKS-D is fully managed by you, unlike Amazon EKS, which is managed by AWS.
- Where:
  - Run EKS-D anywhere; on-premises, in the cloud, or somewhere else.
- You responsibility:
  - Bottom line; you are fully responsible for upgrading and managing your platforms.

## Orchestrating containers outside AWS using Amazon EKS Anywhere and Amazon ECS Anywhere

EKS Anywhere:
- On-premises EKS:
  - An on-premises way to manage Kubernetes (K8s) clusters with the same practices used for Amazon EKS
- EKS Distro:
  - Based on EKS Distro
  - Allows for deployment, usage, and management methods for clusters in data centres.
- Lifecycle:
  - Offers full lifecycle management of multiple K8s clusters.
  - Operates independently of AWS.

ECS Anywhere:
- Feature of Amazon ECS allowing the management of container-based apps on-premises.
- No orchestration needed:
  - No need to install and operate local container orchestration software, meaning more operation efficiency.
- Completely managed:
  - Completely managed solution enabling standardisation of container management across environments.
- Inbound traffic:
  - Keep in mind, no ELB support, makes inbound traffic requirements less efficient.
- External:
  - New launch type noted as `EXTERNAL` for creating services or running tasks.
- Requirements:
  - Must have SSM Agent, ECS agent and Docker installed.
  - First register instances as SSM managed instances.
  - You can easily create an installation script within the ECS console.
  - Scripts contain SSM activation keys and commands for required software.
  - Execute scripts on your on-premises VMs or bare-metal servers.
  - Deploy containers using the `EXTERNAL` launch type.

## Auto-scaling databases on demand with Amazon Aurora serverless

Two terms to be able to differentiate: `Aurora Provisioned` and this one which is `Aurora Serverless:
- On demand:
  - On demand and auto scaling configuration for the Amazon Aurora database service.
- Automate:
  - Automation of monitoring workloads and adjusting capacity for databases.
- Based on demand:
  - Capacity adjusted based on application demands.
- Billing:
  - Charged for resources consumed by DB clusters; per-second billing.
- Budget friendly:
  - Helps customers stay well within budgets via the auto scaling and per-second billing features.

Aurora serverless concepts:
- Aurora capacity units (ACUs): Measurements on how your clusters scale.
- Set minimum and maximum ACUs for scaling requirements (can be zero).
- Allocated (quickly) by AWS-managed warm pools.
- Combination of about 2 GiB of memory, matching CPU, and networking capability.
- Same data resiliency as Aurora provisioned: 6 copies of data across 3 AZs.
- Multi-AZ deployments for establishing highly available clusters.

Use cases:
- Variable workloads:
  - Unpredictable or sudden activity.
- Multi-tenant apps:
  - Let the service manage database capacity for each individual app.
- New apps:
  - Unsure what database instance needs are required.
- Dev and test:
  - Developement or testing of new features.
- Mixed-use apps:
  - App might serve more than one purpose with different traffic spikes.
- Capacity planning:
  - Easily swap from provisioned to serverless and vice-versa.

## AWS X-Ray for application insights

- App insights:
  - Collects application data for viewing, filtering, and gaining insights about requests and responses.
- Downstream:
  - View calls to downstream AWS resources and other microservices/APIs or databases.
- Traces:
  - Receives traces from your applications for allowing insights.
- Multiple options:
  - Integrated services can add tracing headers, send trace data, or run the X-Ray daemon.

Concepts:
- `Segments`: Data containing resource names, request details, and other information.
- `Subsegments`: Segments providing more granular timing information and details.
- `Service graph`: Graphical representation of interacting services in requests.
- `Traces`: Trace ID tracks paths of requests and traces collect all segments in a request.
- `Tracing header`: Extra HTTP header containing sampling decisions and trace ID.
- Tracing header containing added information is named: `X-Amzn-Trace-Id`.

AWS X-Ray daemon:
- AWS software application that listens on `UDP port 2000`.
- It collects raw segment data and sends it to the AWS X-Ray API.
- When the daemon is running, it works along with the AWS X-Ray SDKs.

Integrations:
- EC2:
  - Installed, running agent.
- ECS:
  - Installed within tasks.
- Lambda:
  - Simple on/off toggle and is built-in and available for functions.
- Elastic Beanstalk:
  - Configuration option.
- API Gateway:
  - Added to stages as desired.
- SNS and SQS:
  - View time taken for messages in queues and topics.

## Deploying GraphQL interfaces in AWS AppSync

What is AppSync?
- Robust, scalable GraphQL interface for application developers.
- Combines data from multiple sources e.g. Dynamo DB and Lambda.
- Enables data interaction for developers via GraphQL.
- GraphQL: Data language that enables apps to fetch data from servers.
- Seamless integration with React, React Native, iOS and Android.