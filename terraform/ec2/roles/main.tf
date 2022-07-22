/*
terraform init
terraform apply -var-file="secrets.tfvars"
terraform destroy -var-file="secrets.tfvars"

--------------
Other commands
--------------
ssh -i "key-pair.pem" ec2-user@3.84.75.118

aws s3 ls
2022-07-22 17:06:33 s3-bucket-20220722170632293600000001 <--- NOTE we do not have to "aws configure" as the assumed Role has the "S3 full access" policy attached

echo "Hello" > hello.txt

aws s3 cp hello.txt s3://s3-bucket-20220722170632293600000001
upload: ./hello.txt to s3://s3-bucket-20220722170632293600000001/hello.txt


terraform state list

terraform output

------------
Useful links
------------
https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/modules/iam-user/main.tf
*/