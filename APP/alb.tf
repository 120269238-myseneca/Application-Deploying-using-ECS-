resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_id
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "my-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"  
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_security_group_rule" "ecs_egress_to_rds" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol    = "-1"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id  = data.terraform_remote_state.network.outputs.ecs_task_sg_id

}


resource "aws_security_group_rule" "alb_ingress_from_net" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = data.terraform_remote_state.network.outputs.alb_sg_id

}