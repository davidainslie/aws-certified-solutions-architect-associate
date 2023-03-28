# Governance

## Managing accounts with Organisations

AWS Organisations is a free governance tool that allows you to create and manage multiple AWS accounts.
With it, you can control your accounts from a single location rather than jumping from account to account.

Key features of Organisations:
- Logging accounts:
  - It's best practice to create a specific account dedicated to logging; CloudTrail supports logs aggregation.
- Programmatic creation:
  - Easily create and destroy new AWS accounts.
- Reserver instances:
  - RIs can be shared across all accounts.
- Consolidated billing:
  - The primary account pays the bills.
- Service control policies:
  - SCPs can limit users' permissions.
  - A SCP overrides any other policy; they are the ultimate way to restrict permissions, and even apply to the root account.
  - SCP never give you any permissions, they only take permissions away i.e. narrow down possibly to zero, what other permissions have been granted.

## Sharing resources with AWS RAM
