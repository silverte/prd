# Map 2.0 RDS tag 
# oracle to oracle -> map-migrated / oracleM6LD1XNIQQ 
# 그외              -> map-migrated / commM6LD1XNIQQ   

# Database subnet group for vpc-esp-dev
resource "aws_db_subnet_group" "rds_subnet_group" {
  count       = var.create_db_subnet_group ? 1 : 0
  name        = "rdssg-${var.service}-${var.environment}"
  description = "Database subnet group for ${var.environment}"
  subnet_ids  = data.aws_subnets.database.ids
  tags = merge(
    local.tags,
    {
      Name = "rdssg-${var.service}-${var.environment}"
    },
  )
}

################################################################################
# RDS Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-rds
################################################################################
module "rds-maria" {
  source                    = "terraform-aws-modules/rds/aws"
  create_db_instance        = var.create_mariadb
  create_db_parameter_group = var.create_mariadb
  create_db_option_group    = var.create_mariadb

  identifier = "rds-${var.service}-${var.environment}-${var.rds_mariadb_name}"

  engine                          = var.rds_mariadb_engine
  engine_version                  = var.rds_mariadb_engine_version
  family                          = var.rds_mariadb_family               # DB parameter group
  major_engine_version            = var.rds_mariadb_major_engine_version # DB option group
  parameter_group_name            = "rdspg-${var.service}-${var.environment}-${var.rds_mariadb_name}"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "MariaDB parameter group for ${var.service}-${var.environment}-${var.rds_mariadb_name}"
  instance_class                  = var.rds_mariadb_instance_class
  option_group_name               = "rdsog-${var.service}-${var.environment}-${var.rds_mariadb_name}"
  option_group_use_name_prefix    = false
  option_group_description        = "MariaDB option group for ${var.service}-${var.environment}-${var.rds_mariadb_name}"

  storage_encrypted = true
  storage_type      = "gp3"
  kms_key_id        = data.aws_kms_key.rds.arn
  allocated_storage = var.rds_mariadb_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                     = var.rds_mariadb_db_name
  username                    = var.rds_mariadb_username
  manage_master_user_password = true
  port                        = var.rds_mariadb_port

  multi_az               = true
  db_subnet_group_name   = try(aws_db_subnet_group.rds_subnet_group[0].name, null)
  subnet_ids             = [element(data.aws_subnets.database.ids, 0)]
  vpc_security_group_ids = try([module.security_group["mariadb-solution"].security_group_id], null)

  backup_retention_period    = 7
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  deletion_protection        = true

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # create_monitoring_role                = true
  # monitoring_interval                   = 60
  # monitoring_role_name                  = "role-${var.service}-${var.environment}-${var.rds_mariadb_name}-monitoring"
  # monitoring_role_use_name_prefix       = false
  # monitoring_role_description           = "MariaDB solution for monitoring role"

  parameters = []

  tags = merge(
    local.tags,
    {
      "Name"         = "rds-${var.service}-${var.environment}-${var.rds_mariadb_name}",
      "map-migrated" = "commM6LD1XNIQQ"
    },
  )
}

################################################################################
# RDS Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-rds
################################################################################
module "rds-oracle" {
  source                    = "terraform-aws-modules/rds/aws"
  create_db_instance        = var.create_oracle
  create_db_parameter_group = var.create_oracle
  create_db_option_group    = var.create_oracle

  identifier = "rds-${var.service}-${var.environment}-${var.rds_oracle_name}"

  engine                          = var.rds_oracle_engine
  engine_version                  = var.rds_oracle_engine_version
  family                          = var.rds_oracle_family               # DB parameter group
  major_engine_version            = var.rds_oracle_major_engine_version # DB option group
  parameter_group_name            = "rdspg-${var.service}-${var.environment}-${var.rds_oracle_name}"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "DB parameter group for ${var.service}-${var.environment}-${var.rds_oracle_name}"
  instance_class                  = var.rds_oracle_instance_class
  license_model                   = "bring-your-own-license"
  option_group_name               = "rdsopt-${var.service}-${var.environment}-${var.rds_oracle_name}"
  option_group_use_name_prefix    = false
  option_group_description        = "Option Group for ${var.service}-${var.environment}-${var.rds_oracle_name}"

  storage_encrypted = true
  storage_type      = "gp3"
  kms_key_id        = data.aws_kms_key.rds.arn
  allocated_storage = var.rds_oracle_allocated_storage

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  # Oracle database name cannot be longer than 8 characters
  db_name                     = var.rds_oracle_db_name
  username                    = var.rds_oracle_username
  manage_master_user_password = true
  port                        = var.rds_oracle_port

  multi_az               = false
  availability_zone      = element(local.azs, 0)
  db_subnet_group_name   = try(aws_db_subnet_group.rds_subnet_group[0].name, "")
  subnet_ids             = [element(data.aws_subnets.database.ids, 0)]
  vpc_security_group_ids = try([module.security_group["oracle-solution"].security_group_id], null)

  backup_retention_period    = 7
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  deletion_protection        = true

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # create_monitoring_role                = true
  # monitoring_interval                   = 60
  # monitoring_role_name                  = "role-${var.service}-${var.environment}-${var.rds_oracle_name}-monitoring"
  # monitoring_role_use_name_prefix       = false
  # monitoring_role_description           = "Oracle solution for monitoring role"

  # See here for support character sets https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.OracleCharacterSets.html
  character_set_name       = "AL32UTF8"
  nchar_character_set_name = "AL16UTF16"

  parameters = []

  tags = merge(
    local.tags,
    {
      "Name"         = "rds-${var.service}-${var.environment}-${var.rds_oracle_name}"
      "map-migrated" = "oracleM6LD1XNIQQ"
    },
  )
}

################################################################################
# RDS Aurora Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-rds-aurora
################################################################################
module "aurora-postgresql" {
  source                            = "terraform-aws-modules/rds-aurora/aws"
  create                            = var.create_aurora_postresql
  create_db_cluster_parameter_group = var.create_aurora_postresql

  name                                 = "rds-${var.service}-${var.environment}-${var.rds_aurora_cluster_name}"
  engine                               = var.rds_aurora_cluster_engine
  engine_version                       = var.rds_aurora_cluster_engine_version
  database_name                        = var.rds_aurora_cluster_database_name
  master_username                      = var.rds_aurora_master_username
  manage_master_user_password          = true
  manage_master_user_password_rotation = false
  port                                 = var.rds_aurora_port
  instance_class                       = var.rds_aurora_cluster_instance_class
  instances = {
    1 = {},
    2 = {},
    3 = {}
  }
  # autoscaling_enabled      = true
  # autoscaling_min_capacity = 2
  # autoscaling_max_capacity = 2

  vpc_id               = data.aws_vpc.vpc.id
  db_subnet_group_name = try(aws_db_subnet_group.rds_subnet_group[0].name, null)
  publicly_accessible  = false

  create_security_group  = false
  vpc_security_group_ids = try([module.security_group["aurora-postgresql"].security_group_id], null)

  storage_encrypted                          = true
  storage_type                               = "aurora"
  kms_key_id                                 = data.aws_kms_key.rds.arn
  apply_immediately                          = true
  skip_final_snapshot                        = true
  auto_minor_version_upgrade                 = false
  backup_retention_period                    = 7
  deletion_protection                        = true
  db_cluster_parameter_group_name            = "rdspg-${var.service}-${var.environment}-${var.rds_aurora_cluster_name}"
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_family          = var.rds_aurora_cluster_pg_family
  db_cluster_parameter_group_description     = "aurora cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "orafce.timezone"
      value        = "Asia/Seoul"
      apply_method = "immediate"
      }, {
      name         = "timezone"
      value        = "Asia/Seoul"
      apply_method = "immediate"
    }
  ]

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.create_aurora_postresql ? aws_iam_role.rds_monitoring_role[0].arn : null
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = merge(
    local.tags,
    {
      "Name"         = "rds-${var.service}-${var.environment}-${var.rds_aurora_cluster_name}",
      "map-migrated" = "commM6LD1XNIQQ"
    },
  )
}

resource "aws_iam_role" "rds_monitoring_role" {
  count = var.create_aurora_postresql ? 1 : 0
  name  = "role-${var.service}-${var.environment}-${var.rds_aurora_cluster_name}-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attachment" {
  count      = var.create_aurora_postresql ? 1 : 0
  role       = aws_iam_role.rds_monitoring_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
