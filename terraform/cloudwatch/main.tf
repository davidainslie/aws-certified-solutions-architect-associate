/*
AWS AMIs
https://cloud-images.ubuntu.com/locator/ec2/

terraform init
terraform apply -var-file="secrets.tfvars" -auto-approve
terraform destroy -var-file="secrets.tfvars" -auto-approve

--------------
Other commands
--------------
ssh -i "key-pair.pem" ec2-user@3.84.75.118

sudo su

aws s3 ls <--- If not configured then the first time you will get "You can configure credentials by running 'aws configure'"

aws configure

aws s3 mb s3://my-bucket-055636501164
make_bucket: my-bucket-055636501164

aws s3 ls
2022-07-21 19:14:08 my-bucket-055636501164

echo "Hello" > hello.txt

aws s3 cp hello.txt s3://my-bucket-055636501164
upload: ./hello.txt to s3://my-bucket-055636501164/hello.txt

aws s3 rb s3://my-bucket-055636501164 --force


terraform state list

terraform output

------------
Useful links
------------
https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/modules/iam-user/main.tf
*/