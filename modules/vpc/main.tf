
resource "aws_vpc" "wx" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "wx"
  }
}

resource "aws_internet_gateway" "wx" {
  vpc_id = aws_vpc.wx.id
}

resource "aws_subnet" "wx_public" {
  vpc_id                  = aws_vpc.wx.id
  availability_zone       = var.availability_zone
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "wx"
  }
  depends_on = [aws_internet_gateway.wx]
}

resource "aws_subnet" "wx_private" {
  vpc_id            = aws_vpc.wx.id
  availability_zone = var.availability_zone
  cidr_block        = var.private_cidr
  tags = {
    Name = "wx"
  }
  depends_on = [aws_internet_gateway.wx]
}

locals {
  wx_public_security_group_rules = {
    ingress = {
      "ssh" = {
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr_ipv4 = "0.0.0.0/0"
      }
      "self" = {
        from_port   = -1
        to_port     = -1
        ip_protocol = "-1"
        cidr_ipv4 = var.vpc_cidr
      }
    }
    egress = {
      "anywhere" = {
        from_port   = -1
        to_port     = -1
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
      }
    }
  }
  wx_private_security_group_rules = {
    ingress = {
      "public" = {
        from_port   = -1
        to_port     = -1
        ip_protocol = "-1"
        cidr_ipv4 = var.vpc_cidr
      }
    }
    egress = {
      "anywhere" = {
        from_port   = -1
        to_port     = -1
        ip_protocol = "-1"
        cidr_ipv4 = "0.0.0.0/0"
      }
    }
  }
}

resource "aws_security_group" "wx_public" {
  name   = "aws_public_compute_environment_security_group"
  vpc_id = aws_vpc.wx.id
}

resource "aws_vpc_security_group_ingress_rule" "wx_public_allow_ingress" {
  for_each = local.wx_public_security_group_rules.ingress
  security_group_id = aws_security_group.wx_public.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "wx_public_allow_egress" {
  for_each = local.wx_public_security_group_rules.egress
  security_group_id = aws_security_group.wx_public.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
}

resource "aws_security_group" "wx_private" {
  name = "aws_private_compute_environment_security_group"
  vpc_id = aws_vpc.wx.id
}

resource "aws_vpc_security_group_ingress_rule" "wx_private_allow_ingress" {
  for_each = local.wx_private_security_group_rules.ingress
  security_group_id = aws_security_group.wx_private.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "wx_private_allow_egress" {
  for_each = local.wx_private_security_group_rules.egress
  security_group_id = aws_security_group.wx_private.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
}

resource "aws_route_table" "wx_public" {
  vpc_id = aws_vpc.wx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wx.id
  }
}

resource "aws_route_table_association" "wx_public" {
  subnet_id      = aws_subnet.wx_public.id
  route_table_id = aws_route_table.wx_public.id
}

resource "aws_route_table" "wx_private" {
  vpc_id = aws_vpc.wx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wx.id
  }
}
resource "aws_route_table_association" "wx_private" {
  subnet_id      = aws_subnet.wx_private.id
  route_table_id = aws_route_table.wx_private.id
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "wx" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.wx_public.id
  depends_on    = [aws_internet_gateway.wx]
}
