output "Hostname" {
  value = "${aws_instance.frontend.*.public_dns}"
}

output "IP" {
  value = "${aws_instance.frontend.*.public_ip}"
}

output "SSH_Key"{
  value = "${aws_instance.frontend.*.key_name}"
}

output "RDS_Endpoint"{
  value = "${data.aws_db_instance.database.endpoint}"
}

output "dbname"{
  value = "${data.aws_db_instance.database.db_name}"
}

output "dbuser"{
  value = "${data.aws_db_instance.database.master_username}"
}

