# Decoupling Workflows

![Decouple Workflow](images/decouple-workflow.png)

There are other ways to decouple and avoid using an ELB:
- Simple Queue Service (SQS):
  - A fully managed message queuing service that enables you to decouple and scale microservices, distributed systems and serverless applications.
- Simple Notification Service (SNS):
  - A fully managed messaging service for both application-to-application (A2A) and application-to-person (A2P) communication.
- API Gateway:
  - A fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale.

## Messaging with SQS

Simple Queue Service is a messaging queue that allows `asynchronous` processing of work.
One resource will write a message to a SQS queue, and then another resource will retrieve that message from SQS.

SQS settings:
- Delivery delay: Default is 0; can be set up to 15 minutes.
- Message size: Can be up to 256KB of text in any format.
- Encryption: Messages are encrypted in transit by default; but you can add at-rest.
- Message retention: Default is 4 days; can be set between 1 minute and 14 days.
- Long vs short polling: Short is default.
  - Short: Connect; check for messages; disconnect; and repeat (not efficient and wastes money).
  - Long: Much better - Connect; wait a set amount of time for messages; then disconnect.
- Queue depth: This can a trigger for autoscaling. Best to set up a `CloudWatch` alarm to monitor queue depth.
- Visibility timeout:
  - A resource polls and sees a message - the message is pulled for processing but not immediately removed from the queue.
  - While the message is being processed, the message remains hidden on the queue for 30 seconds i.e. no one else can pick it up.
  - If the message is successfully processed, the resource can let SQS know, and SQS can delete the message.
  - However, the the resource maybe goes down, after the 30 second timeout, the message can be picked up by any other resource.

Sidelining messages with dead-letter queues:
- Say a consumer cannot process a message. Say the message is invalid.
- We could retry the message, but that won't change a thing (we can set a retry count), and then we'll end up in a loop, until the message expires and is deleted.
- Instead, we can have the message off-loaded to a `dead letter` queue, when a message cannot be processed.

Ordered messages with SQS FIFO:
```
Standard:                                             FIFO
message 1 --->                                        message 1 --->
message 2 --->                                        message 2 --->
message 3 --->                                        message 3 --->
message 4 --->                                        message 4 --->
                SQS                                                   SQS
                     ---> message 2                                       ---> message 1
                     ---> message 1                                       ---> message 2
                     ---> message 3                                       ---> message 3
                     ---> message 4                                       ---> message 4
                     ---> message 4
```
FIFO guarantees ordering and no duplicate messages.
What's the catch compared to standard? You are limited to 300 messages per second and of course, cost more.
FIFO messages need a `message group ID` that ensures messages are processed one by one.

## Delivering messages with SNS

Simple Notification Service is `pushed based messaging` as opposed to `poll based` used by SQS.

SNS is a pushed based messaging service, whereby it will proactively deliver messages to the endpoints `subscribed` to it.
This can be used to alert a system or a person.

- Subscribers - What is subscribed to your SNS topic?
  - E.g. Kinesis Data Firehose, SQS, Lambda, email, Http(s), SMS, platform application endpoint.
  - Note, only retries work with Http(s), otherwise a failed notification can go to a DLQ.
- Message size:
  - Messages can be up to 256KB of text in any format.
- DLQ support:
  - Messages that fail to be delivered can be stored in a SQS DLQ.
- FIFO or standard:
  - FIFO only supports SQS as a subscriber.
- Encryption:
  - Messages are encrypted in transit by default, but you can add at-rest.
- Access policy:
  - A resource policy can be added to a topic, similar to S3.

## Fronting applications with API Gateway
