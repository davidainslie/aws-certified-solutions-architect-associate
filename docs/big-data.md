# Big Data

The `3 V's` of big data:
- Volume:
  - Ranges from terabytes to petabytes of data.
- Variety:
  - Includes data from a wide range of sources and formats.
- Velocity:
  - Businesses require speed; data needs to be collected, stored, processed, and analysed within a short period of time.

## Exploring large Redshift databases

Redshift is a fully managed, petabyte-scale data warehouse service in the cloud.
It's a very large relational database traditionally used in big data applications.

Redshift is where you can store massive amounts of data:
- Size:
  - Redshift can hold up to 16 PB of data; this means you don't have to split up your large datasets.
- Relational:
  - This database is relational; use your standard SQL and business intelligence (BI) tools to interact with it.
- Usage:
  - While Redshift is a fantastic tool for BI applications, it is not a replacement for standard RDS databases.

## Processing data with EMR (Elastic MapReduce)

ETL = Extract, Transform, Load

EMR is there to help us with this ETL process.

EMR is a managed big data platform that allows you to process vast amounts of data using open source tools such as Spark, Hive, HBase, Flink, Hudi, and Presto.
It is AWS's ETL tool. In a nutshell, EMR is a managed fleet of EC2 instances running open source tools.

- EC2 rules apply:
  - You can use RIs (reserved instances) and Spot instances to reduce cost.
- VPC:
  - The architecture lives inside a VPC.

## Streaming data with Kinesis

Kinesis allowd you to ingest, process, and analyse real-time streaming data.
You can think of it as a huge data highway connected to your AWS account.

There are 2 major types of Kinesis:

| Data Streams                                                                            | Data Firehose                                                                                |
|-----------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| **Purpose**:<br/>Real-time streaming for ingesting data                                 | **Purpose**:<br/>Data transfer tool to get information to S3, Redshift, Elastisearch, Splunk |
| **Speed**:<br/>Real time                                                                | **Speed**:<br/>Near real time (withing 60 secs)                                              |
| **Difficulty**:<br/>You're responsible for creating the consumer and scaling the stream | **Difficulty**:<br/>Plug and play with AWS architecture                                      |

Kinesis Data Streams is a lot of work compared to Firehose e.g. coding all the necessary consumers.
But there is a lot of work because you have complete control:
![Kinesis data streams](images/kinesis-data-streams.jpg)

![Kinesis data firehose](images/kinesis-data-firehose.jpg)

Kinesis data analytics - Analyse data using standard SQL:
- Easy:
  - It's very simple to tie data analytics into your Kinesis pipeline; it's directly supported by Firehose and Streams.
- No servers:
  - This is a fully managed real-time serverless service; it will automatically handle scaling and provisioning of needed resources.
- Cost:
  - You only pay for the amount of resources you consume as your data passes through.

Why would you use Kinesis instead of SQS?
Kinesis (unlike SQS) is real-time, and you would want to use it with big data.
 
## Amazon Athena and AWS Glue

What is Athena?
- Athena is a serverless interactive query service that makes it easy to analyse data in `S3` using `SQL`.
- This allows you to directly query data in your S3 bucket without loading it into a database.

What is Glue?
- Glue is a serverless data integration service that makes it easy to discover, prepare, and combine data.
- It allows you to perform ETL workloads without managing underlying servers.
- Glue can be used instead of EMR.

![Athena and Glue](images/athena-and-glue.jpg)

## Visualing data with QuickSight

What is QuickSight?
- Amazon QuickSight is a fully managed business intelligence (BI) data visualisation service.
- It allows you to easily create dashboards and share them within your company.

## Moving transformed data using AWS Data Pipeline
