
resource "aws_vpc" "main" {
  cidr_block           = "10.11.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "MyEnvironment VPC",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "MyEnvironment Internet Gateway",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "MyEnvironment Subnet",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}



# Public A
resource "aws_eip" "public_a" {
  vpc = true
}

resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.11.0.0/19"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "Production Subnet (Public A)",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_nat_gateway" "public_a" {
  allocation_id = "${aws_eip.public_a.id}"
  subnet_id     = "${aws_subnet.public_a.id}"

  tags {
    Name = "Production NAT Gateway (Public A)",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}

resource "aws_default_network_acl" "main" {
  default_network_acl_id = "${aws_vpc.main.default_network_acl_id}"
  subnet_ids = ["${aws_subnet.public_a.id}"]
  ingress {
    rule_no = 100
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  ingress {
    rule_no = 200
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    rule_no = 100
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  tags {
    Name = "Production NAT Gateway (Public A)",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}


resource "aws_security_group" "main" {
  name = "Main"
  description = "Main Security Group"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Production NAT Gateway (Public A)",
    OwnerContact = "droyad",
    Environment = "Production",
    Lifetime = "May-2018"
  }
}

resource "aws_elb" "test_elb" {
  name = "Test-elb",
  availability_zones = ["eu-central-1a"],
  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
}


resource "aws_elb" "production_elb" {
  name = "Production-elb",
  availability_zones = ["eu-central-1a"],
  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
}