resource "aws_security_group" "glue_self_ref_sg" {
  name        = "${var.app_name}-glue-sg"
  description = "Security Group for Glue with self-reference rule"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Self reference rule for Glue"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
}

resource "aws_glue_connection" "mysql_connection" {
  name = "${var.app_name}-MySQLConnection"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_db_instance.rds_instance.endpoint}:${aws_db_instance.rds_instance.port}/${var.db_name}"
    USERNAME            = aws_db_instance.rds_instance.username
    PASSWORD            = aws_db_instance.rds_instance.password
  }

  physical_connection_requirements {
    availability_zone      = "ap-northeast-1a"
    security_group_id_list = [aws_security_group.glue_self_ref_sg.id]
    subnet_id              = module.vpc.subnet_ids["public-primary"]
  }
}

resource "aws_iam_role" "glue_job_role" {
  name = "${var.app_name}-glue-etl-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  path = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]
}
