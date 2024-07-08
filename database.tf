# Create DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "DBSubnetGroup"
  }
}

# Create RDS instance
resource "aws_db_instance" "database" {
  identifier                = "test-database" # Adjusted identifier to comply with naming rules
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "8.0.35"
  instance_class            = "db.t3.micro"
  username                  = var.rds_username
  password                  = var.rds_password
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-test-database-snapshot" 

  tags = {
    Name = "TestDatabase"
  }
}
