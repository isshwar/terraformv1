provider "aws" {
	region = "us-east-1"
	alias = "virginia"
}

provider "aws" {
	region = "ap-southeast-1"
	alias = "sing"
}

data "aws_db_instance" "database" {
	provider 	       = "aws.virginia"
	db_instance_identifier = "${var.rds_name}"
}

resource "aws_instance" "frontend" {
	provider 	= "aws.virginia"
	count 	        = "${var.ins_count}"	
	ami 		= "${var.ami}"
	instance_type 	= "${var.instance["type"]}"
	key_name 	= "${var.key_name}"
        disable_api_termination = false
	vpc_security_group_ids = [ "${aws_security_group.frontend_security.id}" ]
	depends_on 	= [ "aws_security_group.frontend_security"]
        provisioner file {
	  source      = "user-data.sh"
          destination = "/tmp/user-data.sh"
          connection {
		type        = "ssh"
		user        = "ubuntu"
		private_key = "${file("/home/ec2-user/.ssh/cfn-key-1.pem")}"
                host        = "${aws_instance.frontend[count.index].public_ip}"
		} 
	}
       provisioner "remote-exec" {
          inline = [
       		"chmod +x /tmp/user-data.sh",
        	"/tmp/user-data.sh" 
		]
          	connection {
                	type        = "ssh"
                	user        = "ubuntu"
                	private_key = "${file("/home/ec2-user/.ssh/cfn-key-1.pem")}"
                        host        = "${aws_instance.frontend[count.index].public_ip}"
                }
        }
#	user_data       = "${file("init.sh")}"
#			   #! /bin/bash -x
#        		   sudo yum install -y nginx
#        		   sudo service nginx start
#        		   sudo chkconfig nginx on
#                          echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
#       		   EOF
	tags = {
		Name 	   = "${var.instance["name"]}"
		App 	   = "devops-demo"
        	Maintainer = "Eswar"
	}
	lifecycle {
		prevent_destroy = false
	}
}

resource "aws_security_group" "frontend_security" {
	provider    = "aws.virginia"
	name        = "frontend_sec"
	description = "Allow traffic over port 80"

  	ingress {
    		from_port   = 80
    		to_port     = 80
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
    	#	description = "allow http on the server"
  	}
	ingress {
                from_port   = 22
                to_port     = 22
                protocol    = "tcp"
                cidr_blocks = [ "34.230.63.171/32", "37.201.214.224/32" ]
        #       description = "allow ssh  on the server on port 22"
        }
  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}
	tags = {
		Name = "frontend_sec"
	}	
}

resource "null_resource" "populate_db_01" {
  
  triggers = {
    rds_instance_id = "${data.aws_db_instance.database.endpoint}"
  }
  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e 's/DBHOST/${data.aws_db_instance.database.address}/g' /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e 's/SQLUSER/${data.aws_db_instance.database.master_username}/g' /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e 's/SQLPASSWORD/${var.rds_pass}/g' /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend[0].public_ip} 'sudo sed -i -e 's/SQLDBNAME/${data.aws_db_instance.database.db_name}/g' /var/www/html/config.ini'"
  }

  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/terraform-ap ubuntu@${aws_instance.frontend.*.public_ip} 'sudo service apache2 restart'"
  }
}

