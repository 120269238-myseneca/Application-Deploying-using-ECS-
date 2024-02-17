data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "aws-cloud-sudeep-s3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.webservers_subnet_id
}

resource "aws_security_group" "rds_sg" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "cloudclub"
  username             = "dbadmin"
  password             = "sudeepsaurabh01"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  db_name   = "employee"
}