/*
terraform init
terraform apply -var-file="secrets.tfvars"
terraform destroy -var-file="secrets.tfvars"

Other commands:
ssh -i "key-pair.pem" ec2-user@3.84.75.118

sudo su

aws s3 ls <--- If not configured then the first time you will get "You can configure credentials by running 'aws configure'"
We can use credentials within e.g. secrets.tfvars

terraform state list

terraform output
*/