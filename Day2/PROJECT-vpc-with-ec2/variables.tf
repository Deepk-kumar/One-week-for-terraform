
variable "instance" {
  type    = string
  default = "t2.micro" // You can set the default instance type if needed
}

variable "ami_map" {
   type    = string
  default = "ami-080e1f13689e07408" 
}
