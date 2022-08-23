# Databases

## Relational Database Service (RDS)

Relational database engines:
- SQL Server
- Oracle
- MySQL
- PostgreSQL
- MariaDB
- Amazon Aurora

A RDS is essentially an EC2 instance, where you can only access 1 of the above 6 databases listed above, providing:
- Up and running in minutes.
- Multi-AZ e.g. primary database in one AZ and secondary in another. So RDS creates an exact copy of your production database in another AZ. 
  - AWS handles the replication for you. When you write to your production database, the write will automatically synchronise to the standby/secondary database.
- Automatic failover capability i.e. when one AZ becomes unavailable, failover to another.
- Automated backups.

RDS is generally used for `online transaction processing (OLTP)` workloads.

Understanding the difference between `online transaction processing (OLTP)` and `online analytical processing (OLAP)`.

| OLTP                                                                                                                 | OLAP                                                                                                                           |
|----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| Processes data from transactions in real time e.g. customer orders; banking transactions; payments; booking systems  | Processes complex queries to analyse historical data e.g. analysing net profit figures from past 3 years and sales forecasting |
| OLTP is all about data processing and completing large numbers of small transactions in real time                    | OLAP is all about data analysis using large amounts of data, as well as complex queries that take a long time to complete      |

Where RDS/OLTP is suitable for say a customer orders table, with fields such as: `name`, `address`, `order status` etc., it is not suitable for analysing large amounts of data.
For that, use a data warehouse like `Redshift` which is optimised for `OLAP`.

## Increasing Read Performance with Read Replicas

A `read replica` is a read-only copy of your primary database.
Great for read-heavy workloads and takes the load off your primary database.
```
            +--------+     read        +-------------+
            | App    +-----------------> Primary     | mydatabase.us-east-1.rds.amazonaws.com
            | Servers+-----------------> Database    |
            +--------+     write       | (us-east-1a)|
                                       +------+------+
                                              |
                                              |
                                              |copy
                                              |
             +---------+    read-only  +------v------+
Clients ----->Bi-Server+---------------> Read        | myreplica.us-west-1.rds.amazonaws.com
             +---------+               | Replica     |
                                       | (us-west-1a)|
                                       +-------------+
```

Amazon RDS read replicas complement Multi-AZ deployments.
The main purpose of read replicas is scalability, whereas the main purpose of Multi-AZ deployments is availability.
(However, you may use a read replica for disaster recovery of the source DB instance either in the same AWS Region or in another Region).

- Unlike Multi-AZ, each read replica has its own DNS endpoint.
- Read replicas can be promoted to be their own databases - this breaks the replication i.e. data is no longer copied as the replica becomes a primary.
- So remember:
  - Scaling read performance: Read replicas primarily used for scaling `not` for disaster recovery.
  - Automatic backups must be enabled in order to deploy a read replica.
  - Multiple read replicas are supported: MySQL, MariaDB, PostgreSQL, Oracle, SQL Server allow up to 5 read replicas per DB instance. 

## Amazon Aurora

This is a MySQL and PostgreSQL compatible relational database engine that combines the speed and availability of high-end commercial databases with the simplicity and cost-effectiveness of open-source databases.
- Up to 5 times better performance than MySQL.
- Up to 3 times better performance than PostgreSQL.
- All while cheaper with similar performance and availability.
- Starts with 10GB and auto scales by 10GB increments up to 128TB.
- Compute resources scale up to 96 vCPUs and 768GB of memory.
- Always have at least 6 copies of your data - 2 copies are contained in each AZ, with a minimum of 3 AZs.
- Transparently handles the loss of up to 2 copies of data without affecting write availability, and up to 3 copies without affecting read availability.
- Storage is self-healing - Data blocks and disks continuously scanned for errors and automatically repaired.
- 3 Aurora replicas available:
  - Aurora replicas: 15 read replicas.
  - MySQL replicas: 5 read replicas with Aurora MySQL. 
  - PostgreSQL replicas: 5 read replicas with Aurora PostgreSQL.
- Automated backups with Aurora (backups do not affect database performance).
- You can take snapshots and share with other AWS accounts (does not affect performance).

There is Amazon Aurora serverless:
- An on-demand, auto-scaling configuration for MySQL and PostgreSQL compatible editions of Aurora.
- Aurora serverless DB cluster automatically starts up; shuts down; scales capacity up or down, based on your application's needs.

## DynamoDB

- This is a fast and flexible NoSQL database service with millisecond latency at any scale.
- Fully managed database and supports both document and key-value data models.
- Flexible data model with reliable performance for mobile, web, gaming, IoT and many other applications.
- Stored on SSD storage.
- Spread across 3 geographically distinct data centres.
- Eventually consistent reads (by default - or strongly consistent reads).
  - Eventually is usually reached within a second.
  - Strongly returns a result that reflects all writes, prior to the read.
- Pay-per-request pricing.
- Encryption at rest using KMS.
- Site-to-site VPN.
- Direct Connect (DX).
- IAM policies and roles.
- Integrates with CloudWatch and CloudTrail.
- VPC endpoints. 

There is DynamoDB Accelerator (DAX):
- Fully managed, highly available, in-memory cache.
- 10x performance of DynamoDB, reducing request time from milliseconds to microseconds. 