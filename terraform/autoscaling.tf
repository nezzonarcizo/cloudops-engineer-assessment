resource "aws_launch_template" "app" {
  name          = "deel-assessment-app-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.instance_sg.security_group_id]
  }

  user_data = base64encode(file("../user_data.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "app-instance"
      Environment = var.environment
    }
  }
}

resource "aws_lb" "apps_lb" {
  name               = "deel-assessment-apps-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.loadbalancer_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "deel-assessment-apps-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.apps_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.apps_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.nimbus.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simple_web_app_tg.arn
  }
}

resource "aws_lb_listener_rule" "reversed_ip_app_rule_https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reversed_ip_app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/reversed-ip"]
    }
  }
}

resource "aws_lb_listener_rule" "reversed_ip_app_rule_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reversed_ip_app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/reversed-ip"]
    }
  }

  
}

resource "aws_lb_target_group" "simple_web_app_tg" {
  name        = "simple-web-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "simple-web-app-tg"
  }
}

resource "aws_lb_target_group" "reversed_ip_app_tg" {
  name        = "reversed-ip-app-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "reversed-ip-app-tg"
  }
}

resource "aws_autoscaling_group" "apps_asg" {
  name                 = "deel-assessment-app-asg"
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  target_group_arns = [aws_lb_target_group.simple_web_app_tg.arn,
                       aws_lb_target_group.reversed_ip_app_tg.arn
                      ]

  tag {
    key                 = "Name"
    value               = "deel-assessment-app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.db]
}