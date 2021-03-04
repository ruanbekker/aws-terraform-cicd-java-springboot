data "aws_vpc" "main" {
  default = false 
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "public"
  }
}

resource "random_shuffle" "private_subnets" {
  input = tolist(data.aws_subnet_ids.private.ids)
  result_count = 3
}

resource "random_shuffle" "public_subnets" {
  input = tolist(data.aws_subnet_ids.public.ids)
  result_count = 3
}