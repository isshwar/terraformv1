variable "ins_count" {
  description = "number of instances to bring"
  default     = 1
}
variable "ami" {
  description = "ami for the instance"
  default     = "ami-04763b3055de4860b"
}
variable "instance_type" {
  description = "type of the instance"
  default     = "t2.micro"
}
# map type variable definition
variable "instance" {
  description = "instance parameters"
  type        = "map"
 
  default = {
    type = "t2.micro"
    name = "tf-frontend-01"
  }
}
variable "key_name" {
  description = "name of the key"
  default     = "cfn-key-1"
}
variable "rds_name" {
  description = "name of the rds instance"
  default     = "devopsdemo-demo"
} 
variable "rds_pass" {
  description = "password of RDS instance"
  default     = "12345678"
}
