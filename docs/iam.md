# IAM

## Secure the Root Account

The `root account` is the email address you used to sign up for AWS.
The root account has `full administrative access` to AWS, so it is important to secure the account - **Set up MFA**.

It is best practise to not log in as `root` but instead create an Admin group with appropriate permissions,
then add administrator users to this group - and so, only log in as an administrator user (not root).

And note that IAM is universal - It does not apply to regions.

## Controlling Users' Actions with IAM Policy Documents

Here is a policy which essentially provides full administrator rights, as everything is allowed:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }]
}
```
The above policy is indeed an AWS managed policy named `AdministratorAccess`.

Normally we would create a policy and assign to one or many of:
- Users (though not recommended, as this approach becomes difficult to manage)
- Groups
- Roles

## Permanent IAM Credentials

- Users: A physical person
- Groups: Functions, such as administrator, developer etc., contains users
- Roles: Internal usage within AWS - Allows one part of AWS to access another part of AWS e.g. allow EC2 to access S3

> The Principle of Least Privilege:
> 
> Only assign a user the `minimum` amount of privileges they need to do their job.

SSO is out of scope - It involves `federation`:
IAM Federation is when you combine an existing account (maybe the one you log into your Windows environment) with AWS,
so that you can use the same credentials to log in to AWS.
Identity Federation uses the SAML standard, which is Active Directory.