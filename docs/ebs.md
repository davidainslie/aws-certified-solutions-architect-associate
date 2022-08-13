# Elastic Block Storage (EBS) and Elastic File System (EFS)

## Elastic Block Storage (EBS)

EBS is storage volume you can attach to your EC2 instances - A virtual hard disk attached to your virtual EC2 instance.

Use them the same way you would use any system disk:
- Create a file system
- Run an operation system
- Run a database
- Store data
- Install applications

Mission critical:
- Production workloads: Designed for mission-critical workloads.
- Highly available: Automatically replicated within a single Availability Zone to protect against hardware failures.
- Scalable: Dynamically increase capacity and change the volume type with no downtime or performance impact to your live systems.

Different types of EBS:
- General purpose SSD, gp2
  - 3 IOPS (input/output operation per second) per GiB up to maximum of 16,000 IOPS per volume.
  - gp2 volumes smaller than 1TB can burst up to 3000 IOPS.
  - Good for boot volumes or development and test applications that are not latency sensitive.
- General purpose SSD, gp3
  - Predictable 3,000 IOPS baseline performance and 125MiB/s.
  - Ideal for applications that require high performance at low cost, such as MySQL, Cassandra, virtual desktops and Hadoop analytics.
  - Can scale up to 16,000 IOPS and 1,000MiB/s for additional fee.
  - gp3 can be 4 times faster than gp2.
- Provisioned IOPS SSD, io1 (legacy)
  - Up to 64,000 IOPS per volume, 50 IOPS per GiB.
  - So use (over gp) if you need more than 16,000 IOPS.
  - Designed for I/O intensive applications, large databases, and latency-sensitive workloads.
  - 99.9% durability.
- Provisioned IOPS SSD, io2
  - Up to 64,000 IOPS per volume, 500 IOPS per GiB.
  - I/O intensive apps, large databases and latency-sensitive workloads.
  - 99.999% durability.

- Throughput optimised HDD, st1
  - Baseline throughput of 40MB/s per TB.
  - Ability to burst up to 250MB/s per TB.
  - Maximum throughput of 500MB/s per volume.
  - Frequently accessed throughput intensive workloads.
  - Big data, data warehouses, ETL, and log processing.
  - Cost effective way to store mountains of data.
  - Cannot be a boot volume.
- Cold HDD, sc1
  - Baseline throughput of 12MB/s per TB.
  - Ability to burst up to 80MB/s per TB.
  - Maximum throughput of 250MB/s per volume.
  - Good choice for colder data requiring fewer scans per day.
  - Good for apps that need the lowest cost and performance is not a factor.
  - Cannot be a boot volume.

| IOPS                                                         | Throughput                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Measure the number of read/write operations per second       | Measures the number of bits read/written per seond (MB/s)    |
| Important metric for quick transactions, low-latency apps, transactional workloads | Important metric for large datasets, large I/O sizes, complex queries |
| Ability to action reads/writes very quickly                  | Ability to deal with large datasets                          |
| Choose Provisioned IOPS SSD (io1 or io2)                     | Choose Throughput Optimised HDD (st1)                        |

## Volumes and Snapshots

- Volumes exist on EBS - Think of a volume as a virtual hard disk.
- You need a minimum of 1 volume per EC2 instance - This is called the `root device volume`, and this would be where your OS is installed.

And what is a `snapshot`?
- Snapshots exist on S3 - This of snapshots as a photograph of the virtual disk/volume.
- Snapshots are a point in time - When you take a snapshot, it is a point-in-time copy of a volume, essentially deltas are stored after the first snapshot.
- For consistent snapshots it is recommended to stop an instance then take a snapshot.
- You can share snapshots in the region they were created - To share to another region, you need to copy them to the destination region first.

Regarding EBS volumes:
- Location: EBS volumes will always be in the same AZ as EC2.
- Resizing: Can resize on the fly (no need to stop or restart the instance).
- Volume type: Can switch volume types e.g. change from `gp2` to `io2` (no need to stop or restart the instance).

## Protecting EBS volumes with encryption

EBS encrypts your volume with a data key using industry standard AES-256 algorithm.
Amazon EBS encryption uses AWS Key Management Service (AWS KMS) customer master keys (CMK) when creating encrypted volumes and snapshots.
So, you manage the key (to encrypt) yourself, or have Amazon manage a key for you.

Steps to encrypt an unencrypted volume:
- Create a snapshot of the unencrypted root device volume (the one with your OS).
- Create a copy of the snapshot and select the encrypt option.
- Create an AMI from the encrypted snapshot.
- Use the AMI to launch new encrypted instances.

## EC2 hibernation

EC2 hiberation preserves the in-memory RAM on persistent storage (EBS).
This makes it much faster to boot up because you do not need to reload the operating system.

When we start our EC2 instance, the following happens:
- Operating system (from EBS) boots up.
- User data script is run (bootstrap scripts).
- Applications start (can take some time).

When you start your instance out of hiberation:
- The Amazon EBS root volume is restored to its previous state.
- The RAM contents are reloaded.
- The processes that were previously running on the instance are resumed.
- Previously attached data volumes are reattached and the instance retains its instance ID.

So, with EC2 hibernation, the instance boots much faster.
The operating system does not need to reboot because the in-memory state (RAM) is preserved.
This is useful for:
- Long running processes.
- Services that take time to initialise.

## Elastic File System (EFS)

- Managed NFS (network file system) that can be mounted on many EC2 instances.
- EFS works with EC2 instances in multiple Availability Zones.
- Highly available and scalable - but it is expensive.
- Uses NFSv4 protocol.
- Compatible with Linux based AMI (Windows not supported).
- Encryption at rest using KMS.
- File system scales automatically - no capacity planning required.
- Pay per use.
- Highly performant:
  - 1000s of concurrent connections i.e. supports thousands of concurrent connections (EC2 instances).
  - 10 Gbps throughput.
  - Petabytes scaling.
- Controlling performance:
  - General purpose; such as web servers, CMS etc.
  - Max I/O; for big data, media processing etc.
- Storage tiers:
  - Standard; for frequently accessed files.
  - Infrequently accessed

Use cases:
- Content management systems: You can easily share content between EC2 instances.
- Web servers: Have just a single folder structure for your website.