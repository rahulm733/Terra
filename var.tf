variable "region" {
  default = "ap-south-1"
}

##############VPC1##################

variable "vpc1_name" {
  default = "POC-VPC-1"
}
variable "vpc1_cidr" {
  default = "192.168.0.0/24"
}
variable "vpc1_PVsubnet" {
  type    = list(string)
  default = ["192.168.0.0/28", "192.168.0.16/28", "192.168.0.32/28", "192.168.0.48/28", "192.168.0.64/28", "192.168.0.80/28", "192.168.0.96/28"]
}
variable "vpc1_PBsubnet" {
  type    = list(string)
  default = ["192.168.0.112/28", "192.168.0.128/28"]
}
variable "vpc1_PVazs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c", "ap-south-1a", "ap-south-1b", "ap-south-1c", "ap-south-1a"]
}
variable "vpc1_PBazs" {
  type    = list(string)
  default = ["ap-south-1b", "ap-south-1c"]
}

##############VPC2##################

variable "vpc2_name" {
    default = "POC-VPC-2"
}
variable "vpc2_cidr" {
    default = "192.168.1.0/24"
}
variable "vpc2_PVsubnet" {
    type = list(string)
    default = ["192.168.1.0/28","192.168.1.16/28","192.168.1.32/28","192.168.1.48/28","192.168.1.64/28","192.168.1.80/28","192.168.1.96/28"]
}
variable "vpc2_PBsubnet" {
    type = list(string)
    default = ["192.168.1.112/28","192.168.1.128/28"]
}
variable "vpc2_PVazs" {
    type = list(string)
    default = ["ap-south-1a","ap-south-1b","ap-south-1c","ap-south-1a","ap-south-1b","ap-south-1c","ap-south-1a"]
}
variable "vpc2_PBazs" {
    type = list(string)
    default = ["ap-south-1b","ap-south-1c"]
}

##############VPC3##################

variable "vpc3_name" {
    default = "POC-VPC-3"
}
variable "vpc3_cidr" {
    default = "192.168.2.0/24"
}
variable "vpc3_PVsubnet" {
    type = list(string)
    default = ["192.168.2.0/28","192.168.2.16/28","192.168.2.32/28","192.168.2.48/28","192.168.2.64/28","192.168.2.80/28","192.168.2.96/28"]
}
variable "vpc3_PBsubnet" {
    type = list(string)
    default = ["192.168.2.112/28","192.168.2.128/28"]
}
variable "vpc3_PVazs" {
    type = list(string)
    default = ["ap-south-1a","ap-south-1b","ap-south-1c","ap-south-1a","ap-south-1b","ap-south-1c","ap-south-1a"]
}
variable "vpc3_PBazs" {
    type = list(string)
    default = ["ap-south-1b","ap-south-1c"]
}
