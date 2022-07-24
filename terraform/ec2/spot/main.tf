/*
terraform init
terraform apply -var-file="secrets.tfvars"
terraform destroy -var-file="secrets.tfvars"

--------------
Other commands
--------------
ssh -i ./key-pair.pem ec2-user@44.204.207.12

sudo su

curl http://169.254.169.254/latest/meta-data
ami-id
ami-launch-index
ami-manifest-path
.....

curl http://169.254.169.254/latest/user-data
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>404 - Not Found</title>
 </head>
 <body>
  <h1>404 - Not Found</h1>
 </body>
</html>
*/