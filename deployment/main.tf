provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# Create an ECR repository for the Docker image (if not created earlier)
# resource "aws_ecr_repository" "node_app" {
#   name = "hola_mundo_cloud-repo"
# }

# Create an ECS cluster using EC2
resource "aws_ecs_cluster" "node_app_cluster" {
  name = "HolaMundoCloud-cluster"
}

# IAM role for the ECS task execution
resource "aws_iam_role" "ecs_role" {
  name = "ecs_role_HolaMundoCloud"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role = "${aws_iam_role.ecs_role.name}"

  // This policy adds logging + ecr permissions
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create the Launch Template
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-launch-template-"
  image_id      = "ami-0e593d2b811299b15"  # Amazon Linux 2 AMI, change to the latest in your region
  instance_type = "t2.micro"               # Free tier eligible instance type
  # Use an existing key pair
  key_name = var.aws_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  # Script to configure the instance, install Docker, and run the Node.js app as a Docker container
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update the instance
              sudo yum update -y

              # Install Docker
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user

              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

              # Install Git
              sudo yum install -y git
              EOF
  )
}

# Auto Scaling group to manage the EC2 instances for the ECS cluster
resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  min_size             = 1
  max_size             = 5  # Adjust max_size to allow multiple instances
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tag {
    key                 = "Name"
    value               = "HolaMundoCloud ECS Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "scale_up_on_cpu"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name  = aws_autoscaling_group.ecs_autoscaling_group.name
  metric_aggregation_type = "Average"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high_cpu_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  alarm_actions       = [aws_autoscaling_policy.cpu_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ecs_autoscaling_group.name
  }
}

# ECS instance profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile_HolaMundoCloud"
  role = aws_iam_role.ecs_instance_role.name
}

# IAM role for ECS EC2 instances
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole_HolaMundoCloud"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

# ECS Task Definition
resource "aws_ecs_task_definition" "node_app_task" {
  family                   = "HolaMundoCloud-task"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  memory                   = "512"
  cpu                      = "256"

  container_definitions = jsonencode([
    {
      name      = "HolaMundoCloud",
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/HolaMundoCloud:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000  # Change hostPort to match the containerPort if using awsvpc
        }
      ]
    }
  ])
}

# ECS Service to manage the running tasks
resource "aws_ecs_service" "node_app_service" {
  name            = "HolaMundoCloud-service"
  cluster         = aws_ecs_cluster.node_app_cluster.id
  task_definition = aws_ecs_task_definition.node_app_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}