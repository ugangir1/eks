resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  depends_on = [
   aws_vpc.main
  ]

  tags = {
    Name = "main"
  }
}

output "IG"{
  value = aws_internet_gateway.gw.id
  description = "INternet Gateway"
}
