resource "aws_vpc" "default" {
  cidr_block = var.cidr_block
}

#This block will fetch availability zones in cuurent region.
data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = var.max_capacity
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.default.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = var.max_capacity
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.default.id
}

# internet gateway for the public subnet
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}

#route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = var.open_cidr
  gateway_id             = aws_internet_gateway.gateway.id
}

#create a NAT gateway with elastic IP for each private subnet to get internet  
resource "aws_eip" "gateway" {
  count      = var.max_capacity
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = var.max_capacity
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

#create a new route table for the private subnet, make it route non-local traffic
resource "aws_route_table" "private" {
  count  = var.max_capacity
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = var.open_cidr
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = var.max_capacity
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}