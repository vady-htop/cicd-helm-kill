

# Create the VPC
resource "aws_vpc" "ctd_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames

tags = {
    Name = "CTD VPC"
}
} # end resource


# Create subnets
resource "aws_subnet" "atd_sn" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.ctd_vpc.id

  tags = map(
    "Name", "terraform-eks-ctd-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
} # end resource


# Create internet gatway
resource "aws_internet_gateway" "ctd_ig" {
  vpc_id = aws_vpc.ctd_vpc.id

  tags = {
    Name = "ctd-ig"
  }
} # end resource


# Create Route Table
resource "aws_route_table" "ctd_rt" {
  vpc_id = aws_vpc.ctd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ctd_ig.id
  }
} # end resource


# Attach subnets to Route Table
resource "aws_route_table_association" "ctd_rta" {
  count = 2

  subnet_id      = aws_subnet.atd_sn.*.id[count.index]
  route_table_id = aws_route_table.ctd_rt.id
}
