# Caching

We have 4 main options:
- CloudFront (external)
- ElastiCache (internal)
- DAX (internal) for DynamoDB
- Global Accelerator (external)

## Global caching with CloudFront

CloudFront is a fast content delivery network (`CDN`) service that securely delivers data, videos, applications, and APIs to customers globally.
It helps `reduce` latency and provide higher transfer speeds using AWS `edge locations`.

Without CloudFront:
```
                                 +----------+
                                 |    S3    |
+------+                         | American |
|Europe|------------------------>|   Cat    |
+------+     Very long distance  |  Photos  |
                                 |          |
                                 +----------+
```

With CloudFront:
```
                                                           +----------+
+--------+              +-------------+                    |   S3     |
| Europe |------------->|CloudFront   |------------------->| American |
+--------+              |Edge Location|                    |  Cat     |
                        +-------------+                    |  Photos  |
                                                           +----------+
```

For the first user, there will be no `cat` photos in the edge location, so CloudFront will forward on the request to S3.
However, the results will now be cached in the edge location, for all subsequent requests.

Some important CloudFront settings:
- Security:
  - Defaults to HTTPS connections with the ability to add custom SSL certificate.
- Global distribution:
  - You can't pick specific countries; just general areas of the globe.
- Endpoint support:
  - Can be used to front AWS endpoints along with non-AWS applications.
- Expiring content:
  - You can force an expiration of content from the cache if you can't wait for the `TTL` (time to live).
- Speed:
  - CloudFront's main purpose is to cache content at the edge locations to speed up delivery of data.
- Blocking connections:
  - It can be used to block individual countries, but `WAF` is a better tool for this.
- On-site support:
  - This CDN works for both AWS and on-site architecture.

## Caching your data with ElastiCache and DAX

ElastiCache is a `managed version` of two open source technologies: `Memcached` and `Redis`, that excel being placed in front of a RDS.

| Memcached                        | Redis                                      |
|----------------------------------|--------------------------------------------|
| Simple database caching solution | Supported as a caching solution            |
| Not a database by itself         | Functions as a standalone (NoSQL) database |
| No failover or multi-AZ support  | Failover and multi-AZ support              |
| No backups                       | Supports backups                           |

DynamoDB Accelerator (DAX):
- In memory cache:
  - DAX can reduce DynamoDB response times from millseconds to microseconds.
- Location, Location:
  - This cache is highly available and lives inside the VPC you specify.
- You are in control:
  - You determine the node size and count for the cluster, TTL for the data, and maintenance windows for changes and updates.

## Fixing IP caching with Global Accelerator

Global Accelerator is a networking service that sends your users' traffic through AWS's global network infrastructure.
It can increase performance and help deal with `IP caching`.

```
                                                                                 +-------------+
                                                            +------------------->| EC2         |
                                                            |                    | <cat photos>|
                                                            |                    +-------------+
                                                            |
                                                            |
+------------+             +--------------+           +-----+------+
| Happy      |------------>| Global       |---------->| ELB        |              +------------+
| User       |             | Accelerator  |           | IP: 1.2.3.4|------------->|EC2         |
| IP: 7.7.7.7|             | IP: 7.7.7.7  |           +-----+------+              |<cat photos>|
+------------+             |     5.5.5.5  |                 |                     +------------+
                           +--------------+                 |
                                                            |
                                                            |
                                                            |                     +------------+
                                                            +-------------------->|EC2         |
                                                                                  |<cat photos>|
                                                                                  +------------+
```

Global Accelerator:
- Masks complex architecture:
  - As you applications grow and change, and deployments happen, your users won't notice; they will use the same IPs no matter what.
- Speeds things up:
  - Traffic is routed through AWS's global network infrastructure.
- Weighted pools:
  - You can create weighted groups behind the IPs to test out new features or handle failure in your environment.
- Solves IP caching issue:
  - A client (such as browser) caches IP, but without Global Accelerator, if ELB crashes and reboots, it will have a different IP.