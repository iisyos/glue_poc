# Security Group for EC2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.app_name}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ec2-sg"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.app_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "ec2_instance" {
  ami                         = "ami-07d6bd9a28134d3b3"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.subnet_ids["public-primary"]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y mysql

    # RDS接続スクリプトの作成
    cat > /home/ssm-user/connect_to_rds.sh <<'SCRIPT'
    #!/bin/bash

    DB_ENDPOINT="${aws_db_instance.rds_instance.endpoint}"
    DB_USER="${aws_db_instance.rds_instance.username}"
    DB_PASSWORD="${aws_db_instance.rds_instance.password}"
    DB_NAME="${aws_db_instance.rds_instance.db_name}"

    mysql -h $DB_ENDPOINT -u $DB_USER -p$DB_PASSWORD $DB_NAME
    SCRIPT

    # スクリプトに実行権限を付与
    chmod +x /home/ssm-user/connect_to_rds.sh
    # ssm-userが所有者になるように変更
    chown ssm-user:ssm-user /home/ssm-user/connect_to_rds.sh
  EOF
}

output "ec2_instance_id" {
  value = aws_instance.ec2_instance.id
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "session_manager_command" {
  value = "aws ssm start-session --target ${aws_instance.ec2_instance.id}"
}
