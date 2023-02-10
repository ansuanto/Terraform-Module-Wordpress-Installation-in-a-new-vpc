module "vpc" {
  source      = "/var/terraform/modules/vpc"
  vpc_cidr    = var.project_vpc_cidr
  subnets     = var.project_subnets
  project     = var.project_name
  environment = var.project_environment
}
module "sg-bastion" {
  source         = "/var/terraform/modules/sgroup"
  project        = var.project_name
  environment    = var.project_environment
  sg_name        = "bastion"
  sg_description = "bastion security group"
  sg_vpc         = module.vpc.vpc_id
}
resource "aws_security_group_rule" "bastion-production" {
  count             = var.project_environment == "prod" ? 1 : 0
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["122.171.16.167/32"]
  security_group_id = module.sg-bastion.sg_id
}
resource "aws_security_group_rule" "bastion-development" {
  count             = var.project_environment == "dev" ? 1 : 0
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = module.sg-bastion.sg_id
}
module "sg-frontend" {
  source         = "/var/terraform/modules/sgroup"
  project        = var.project_name
  environment    = var.project_environment
  sg_name        = "frontend"
  sg_description = "frontend  security group"
  sg_vpc         = module.vpc.vpc_id
}
resource "aws_security_group_rule" "frontend-web-access" {
  for_each          = var.frontend-webaccess-ports
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = module.sg-frontend.sg_id
}
resource "aws_security_group_rule" "frontend-remote-access" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg-bastion.sg_id
  security_group_id        = module.sg-frontend.sg_id
}
module "sg-backend" {
  source         = "/var/terraform/modules/sgroup"
  project        = var.project_name
  environment    = var.project_environment
  sg_name        = "backend"
  sg_description = "backend  security group"
  sg_vpc         = module.vpc.vpc_id
}
resource "aws_security_group_rule" "backend-ssh-access" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = module.sg-bastion.sg_id
  security_group_id        = module.sg-backend.sg_id
}
resource "aws_security_group_rule" "backend-db-access" {
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  source_security_group_id = module.sg-frontend.sg_id
  security_group_id        = module.sg-backend.sg_id
}
#create key pair in the name "key" in the project directory.
resource "aws_key_pair" "mykey" {
  key_name   = "${var.project_name}-${var.project_environment}"
  public_key = file("key.pub")
  tags = {
    Name = "${var.project_name}-${var.project_environment}"
  }
}
#template file of database(backend)
data "template_file" "db_installation_userdata" {
  template = file("db-userdata.sh")
  vars = {
    ROOT_PASSWORD     = var.db_root_password
    DATABASE_NAME     = var.db_extra_dbname
    DATABASE_USER     = var.db_extra_username
    DATABASE_PASSWORD = var.db_extra_password
    DATABASE_HOST     = var.db_extra_host
  }
}
#bastion instance
resource "aws_instance" "bastion" {
  ami                    = var.instance_ami[var.aws_region]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  subnet_id              = module.vpc.subnet_public2_id
  vpc_security_group_ids = [module.sg-bastion.sg_id]
  tags = {
    Name = "${var.project_name}-${var.project_environment}-bastion"
  }
}
resource "aws_instance" "backend" {
  ami                    = var.instance_ami[var.aws_region]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  subnet_id              = module.vpc.subnet_private1_id
  vpc_security_group_ids = [module.sg-backend.sg_id]
  user_data              = data.template_file.db_installation_userdata.rendered
  tags = {
    Name = "${var.project_name}-${var.project_environment}-backend"
  }
  depends_on = [module.vpc.nat, module.vpc.rt_private, module.vpc.rt_association_private]
}
#frontend userdata template
data "template_file" "frontend" {
  template = file("${path.module}/userdata.sh")
  vars = {
    localaddress = "${aws_instance.backend.private_ip}"
  }
}
#frontend instance creation
resource "aws_instance" "frontend" {
  ami                    = var.instance_ami[var.aws_region]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.id
  subnet_id              = module.vpc.subnet_public1_id
  vpc_security_group_ids = [module.sg-frontend.sg_id]
  user_data              = data.template_file.frontend.rendered
  tags = {
    Name = "${var.project_name}-${var.project_environment}-frontend"
  }
  depends_on = [aws_instance.backend]
}
resource "aws_eip" "frontend" {
  vpc      = true
  instance = aws_instance.frontend.id
  tags = {
    "Name" = "frontend-ip"
  }
}
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "wordpress.${var.domain_name}"
  type    = "A"
  ttl     = 5
  records = [aws_eip.frontend.public_ip]
}
