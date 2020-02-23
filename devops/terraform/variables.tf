#
# Variables Configuration
#


variable "region" {
     default = "us-east-1"
}


variable "cluster-name" {
  default = "coding-task-devops"
  type    = string
}


variable "InstanceType" {
     default = "t3.micro"
}


variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}


variable "instanceTenancy" {
    default = "default"
}

variable "dnsSupport" {
    default = true
}


variable "dnsHostNames" {
    default = true
}


variable "access_key" {
     default = "PLACE YOUR AWS KEY HERE"
}


variable "secret_key" {
     default = "PLACE YOUR AWS SECRET"
}
