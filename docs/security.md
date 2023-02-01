# Security

## DDoS

A Distributed Denial of Service (DDoS) attack is an attack that attempts to make your website or application unavailable to your end users.
This can be achieved by multiple mechanisms, such as large packet floods, by using a combination of reflection and amplification techniques, or by using large botnets.

SYN flood attack i.e. Layer 4 DDoS attack:
- A layer 4 DDoS attack is often referred to as a `SYN flood`; it works at the transport layer (TCP).
- To establish a TCP connection a 3-way handshake takes place; the client sends a SYN packet to a server, the server replies with a SYN-ACK, and the client then responds to that with an ACK.
- What should happen?
  - After the 3-way handshake is complete, the TCP connection is established; after this, applications begin sending data using Layer 7 (application layer protocol), such as HTTP etc.
- SYN floods:
  - A SYN flood uses the built in patience of the TCP stack to overwhelm a server by sending a large number of SYN packets and then ignoring the SYN-ACKs returned by the server.
  - This causes the server to use up resources waiting for a set amount of time for the anticipated ACK that should come from a legitimate client.
- What can happen?
  - There are only so many concurrent TCP connections that a web or application server can have open, so if an attacker sends enough SYN packets to a server, it can easily eat through the allowed number of TCP connections.
  - This then prevents legitimate requests from being answered by the server.

Amplification attack:
- Amplification/reflection attacks can include things such as NTP, SSDP, DNS, CharGEN, SNMP attacks, etc.
- This is where an attacker may send a third-party server (such as an NTP server) a request using a spoofed IP address.
- The server then responds to the request with a greater payload (than original request), usually around 28-64 times larger, back to the spoofed IP address.
- This means that if the attacker sends a packet with a spoofed IP address of 64 bytes, the NTP server would respond with up to 3,456 bytes of traffic.
- Attackers can coordinate this and use multiple NTP servers a second to send legitimate NTP traffic to the target.

![Spoofing](images/spoofing.jpg) 

Layer 7 attack:
- A Layer 7 attack occurs where a webserver receives a flood of GET or POST requests, usually from a botnet or a large number of compromised computers.

## Logging API calls with CloudTrail

- AWS CloudTrail increases visibility into your user and resource activity by recording AWS management console actions and API calls.
- You can identify which users and accounts called AWS, the source IP address from which the calls were made, and when the calls occurred.
- The logs are stored in S3.

## Protecting applications with Shield

Shield gives free DDoS protection:
- Protects all AWS customers on Elastic Load Balancing (ELB), Amazon CloudFront, and Route 53.
- Protects against SYN/UDP floods, reflection attacks, and other Layer 3 and Layer 4 attacks.

AWS Shield Advanced:
- Provided enhanced protections for your applications running on ELB, CloudFront and Route 53 against larger and more sophisticated attacks.
- Offers always-on, flow-based monitoring of network traffic and active application monitoring to provid near real-time notifications of DDoS attacks.
- Gives you 24/7 access to the DDoS Response Team (DRT) to help manage and mitigate application-layer DDoS attacks.
- Protects your AWS bill against higher fees due to ELB, CloudFront, and Route 53 usage spikes during a DDos attack.
- Costs `$3000 per month` (ouch).

## Filtering traffic with AWS WAF

AWS WAF operates at Layer 7.

AWS WAF is a `web application firewall` that lets you monitor the HTTP and HTTPS requests that are forwarded to Amazon CloudFront or an Application Load Balancer.
AWS WAF also lets you control access to your content.

You can configure conditions such as what IP addresses are allowed to make this request or what query string parameters need to be passed for the request to be allowed.
The Application Load Balancer or CloudFront will either allow this content to be received or give a HTTP 403 status code.

3 ways to control the WAF behaviour:
- Allow all requests except the ones you specify.
- Block all requests except the one you specify.
- Count the requests that match the properties you specify.

You can define conditions by using characteristics of web requests such as:
- IP addresses that requests originate from.
- Country that requests originate from
- Values in request headers
- Presence of SQL code that is likely to be malicious (known as SQL injection).
- Presence of a script that is likely to be malicious (known as cross-site scripting).
- Strings that appear in requests; either specific strings or strings that match regular expression (regex) patterns.

## Guarding your network with GuardDuty

Essentially, GuardDuty is thread detection with AI.

GuardDuty is a threat detection service that uses machine learning to continuously monitor for malicious behaviour.
- Unusual API calls; calls from a known malicious IP.
- Attempts to disable CloudTrail logging.
- Unauthorised deployments.
- Compromised instances.
- Reconnaissance by would-be attackers.
- Port scanning; failed logins.

GuardDuty features:
- Alerts appear in the GuardDuty console and CloudWatch Events.
- Receives feeds from third parties like Proofpoint and CrowdStrike, as well as AWS Security, about known malicious domains and IP addresses.
- Monitors CloudTrail logs, VPC Flow logs, and DNS logs.
- Centralise threat detection across multiple AWS accounts.
- Automated response using CloudWatch Events and Lambda.
- Machine learning and anomaly detection.

It takes around 7 to 14 days to set a baseline - What is normal behaviour on your account?
Once active, you will see findings on the GuardDuty console and in CloudWatch Events only if GuardDuty detects behaviour it considers a threat.

First 30 days are free, then cost is based on:
- Quantity of CloudTrail events.
- Volume of DNS and VPC Flow logs data.

## Centralising WAF management via AWS Firewall Manager

Firewall Manager is a security management service in a single pane of glass.
This allows you to centrally set up and manage firewall rules across multiple AWS accounts and applications in AWS organisations.

Using Firewall Manager, your can create new AWS WAF rules for your Application Load Balancers, API gateways, and CloudFront distributions.
You can also mitigate DDoS attacks using Shield Advanced.

Benefits:
- Simplify management of firewall rules across your accounts.
  - One single pane of glass allows you to manage security across multiple AWS services and accounts.
- Ensure compliance of existing and new applications.
  - Firewall manager automatically enforces security policies that you create across existing and newly created resources, across multiple accounts.

## Monitoring S3 buckets with Macie

Personal Identifiable Information (PII):
- Personal data used to establish an individual's identity.
- This data could be exploited by criminals, used in identity theft and financial fraud.
- Home address, email address, Social Security number.
- Passport number, driver's license number.
- Date of birth, phone number, bank account, credit card number.

`Macie` uses machine learning and pattern matching to discover sensistive data stored in S3:
- Uses AI to recognise if your S3 objects contain sensitive data, such as PII, PHI (personal health information), and financial data.
- Alerts you to unencrypted buckets.
- Alerts you about public buckets.
- Can also alert you about buckets shared with AWS accounts outside of those defined in your AWS organisations.
- Great for frameworks like HIPAA (USA) and GDPR (UK).

Macie can:
- You can filter and search Macie alerts in the AWS console.
- Alerts sent to Amazon EventBridge can be integrated with your security incident and event management system (SIEM).
- Can be integrated with AWS Security Hub for a broader analysis of your organisation's security posture.
- Can also be integrated with other AWS services, such as Step Functions, to automatically take remediation actions.

## Securing operating systems with Inspector

Amazon Inspector is an automated security assessment service that helps improve the security and compliance of applications deployed on AWS.
It automatically assesses applications for vulnerabilities or deviations from best practices.

After performing an assessment, Amazon Inspector produces a detailed list of security findings prioritised by level of severity.
These findings can be reviewed directly or as part of detailed assessment reports that are available via the Inspector console or API.

2 types of assessment:
- Network assessments:
  - Network configuration analysis to checks for ports reachable from outside the VPC.
  - Inspector agent is `not` required.
- Host assessments:
  - Vulnerable software (CVE), host hardening (CIS benchmarks), and security best practices.
  - Inspector agent `is` required.

Steps are:
- Create assessment target.
- Install agents on EC2 instances - AWS will automatically install the agent for instances that allow Systems Manager Run Command.
- Create assessment template.
- Perform assessment run.
- Review findings against rules.

## Managing encyption keys with Key Management Service (KMS) and CloudHSM

AWS Key Management Service (KMS) is a managed service that makes it easy for you to create and control the encryption keys used to encrypt your data.

KMS provides you with centralised control over the lifecycle and permissions of your keys.
You can create new keys whenever you wish, and you can control who can manage keys separately from who can use them.

A customer master key (CMK) is a logical representation of a master key.
The CMK includes metadata, such as the key ID, creation date, description and key state.
It also contains the key material used to encrypt and decrypt data.

You start using the service by requesting the creation of a CMK.
You control the lifecycle of the CMK as well as who can use or manage it.

A hardware security module (HSM) is a physical computing device that safeguards and manages digital keys and performs encryption and decryption functions.
A HSM contains one or more secure cryptoprocessor chips.

3 ways to generate a CMK:
- AWS creates the CMK for you; the key materal for a CMK is generated within HSMs managed by AWS KMS.
- Import key materal from your own key management infrastructure and associate it with a CMK.
- Have the key materal generated and used in an AWS CloudHSM cluster as part of the custom key store feature in AWS KMS.

Policies:
- The primary way to manage access to your AWS KMS CMKs is with policies; where policies are documents that describe who has access to what.
- Policies attached to an IAM identity are called `identity-based policies` (or `IAM policies`); whereas policies attached to other kinds of resources are called `resource-based policies`.
- In AWS KMS, you must attach resource-based policies to your customer master keys (CMKs); these are called `key policies`.

AWS CloudHSM is a cloud-based HSM that enables you to easily generate and use your own encryption keys on the AWS cloud.
It is a physical device, entirely dedicated to you, that can be deployed in a highly available fashion.

| KMS                                   | vs   | CloudHSM                                  |
|---------------------------------------|-----|-------------------------------------------|
| Shared tenancy of underlying hardware |     | Dedicated HSM to you                      |
| Automatic key rotation                |     | Full control of underlying hardware       |
| Automatic key generation              |     | Full control of users, groups, keys, etc. |
|                                       |     | No automatic key rotation                 |

## Storing your Secrets in Secrets Manager

Secrets Manager is a service that securely stores, encrypts and rotates your database credentials and other secrets.
- Encryption in transit and at rest using KMS.
- Automatically rotates credentials.
- Apply fine-grained access control using IAM policies.
- Costs money but is highly scalable.
- Your application makes an API call to Secrets Manager to retrieve the secret programmatically.
- Reduces the risk of credentials being compromised.
- What can be stored?
  - RDS credentials.
  - Credentials for non-RDS databases.
  - Any other type of secret, provided you can store as a key/value pair e.g. ssh keys, API keys etc.

Watch out: If you enable rotation, Secrets Manager immediately rotates the secret once to test the configuration.

## Storing your Secrets in Parameter Store

Parameter Store is a capability of AWS Systems Manager that provides secure, hierarchical storage for configuation data management and secrets management.
You can store data such as passwords, database strings, Amazon Machine Images (AMI) IDs, and licence codes as parameter values.
You can store values as plain text or encrypted data.

Parameter Store is `free` - What is the catch? There's no catch, just limitations when compared to Secrets Manager:
- Limit to the number of parameters you can store (currently 10,000).
- No key rotation.

## Temporarily sharing S3 objects using presigned URLs or Cookies

All objects in S3 are private by default.

Only the object owner has permission to access these objects.
However, the object owner can optionally share objects with others by creating a presigned URL, using their own security credentials, to grant time-limited permission to download the objects.

When you create a presigned URL for your object:
- you must provide your security credentials
- specify a bucket name
- an object key
- and indicate the HTTP method (or GET to download)
- as well as expiration date and time

Anyone who receives the presigned URL can access the object.
For example, if you have a video in your bucket and both e bucket and the object are private, your can share the video with others by generating a presigned URL.

Presigned Cookies:
- This can be useful when you want to provide access to multiple restricted files.
- The cookie will be saved on the user's computer, and they will be able to browse the entire contents of the restricted content.

## Advanced IAM policy documents

![ARN](images/arn.jpg)

IAM policies:
- JSON document that defines permissions
- Identity policy
- Resource policy
- No effect until attached
- List of statements
- Not explicitly allowed == implicitly denied
- Explicit deny > everything else
- AWS joins all applicable policies
- AWS managed vs customer managed

example (template):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    ...
  }, {
    ...
  }]
}
```
A policy document is a list of `statements`.

Each statement matches an `AWS API request`.

## AWS Certificate Manager

- AWS Certificate Manager allows you to create, manage, deploy public and private SSL certificates for use with other AWS services.
- It integrates with other services such as Elastic Load Balancer, CloudFront distributions, API Gateway; allowing you to easily manage and deploy SSL certificates in your AWS environment.
- Cost:
  - Certificate Manager provisions both public and private certificates for free.
- Automated renewals and deployments:
  - Certificate Manager can automate the renewal of your SSL certificate and then automatically update the new certificate with ACM-integrated services such as Elastic Load Balancer, CloudFront, API Gateway.
- Easy to set up:
  - Removes a lot of the manual process, such as generating a key pair or creating a certificate signing request (CSR).

## Auditing continuously with AWS Audit Manager

- With Audit Manager you can continuously audit your AWS usage to make sure you stay compliant with industry standards and regulations.
- It is an automated service that produces reports specific to auditors for PCI compliance, GDPR and more.
- Transition from manual to automated evidence collection:
  - It allows you to produce automated reports for auditors and reduces the need to compile these reports manually.
- Continuous auditing and compliance:
  - It works on a continuous basis so that, as your AWS environment evolves and adapts, you can produce automated reports to evaluate your environment against industry standards (such as PCI compliance).
- Internal risk assessments:
  - You can create a new framework from the beginning or customise prebuilt frameworks.
  - You can also launch assessments to automatically collect evidence helping you validate if your internal policies are being followed.

## Downloading compliance documents from AWS Artifact

Artifact is a single source you can visit to get the compliance related information that matters to you, such as AWS security and compliance reports or select online agreements.

There are a huge number of compliance reports available such as:
- AWS Service Organisation Control (SOC) reports.
- Payment Card Industry (PCI) reports.
- GDPR reports.
- And other certifications, including ISO reports, HIPAA and more.