output "vpc_id" {
  value = aws_vpc.main_cidr.id
}


output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
}

output "webservers_subnet_id" {
  value = aws_subnet.webservers_private.*.id
}

output "ecs_task_sg_id" {
  value = aws_security_group.ecs_tasks_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}