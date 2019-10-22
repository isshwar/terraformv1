#! /bin/bash -x
exec > >(tee /var/log/bootstrap.log) 2>&1
sudo yum install -y nginx
sudo service nginx start
sudo chkconfig nginx on
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
