# Terraform-Module-Wordpress-Installation-in-a-new-vpc

To ensure the reusablity of code, we write the code in modules.

In this repository, I have created a new AWS-Infra(vpc) with public and private subnets via terraform.

Here I am using 3 servers:

> 1.Bastion/jumpbox(public subnet)

> 2.Database(private subnet)

> 3.Webserver(public subnet)

We can ssh to database or webserver, only via bastion server.

After creating the infra, wordpress is installed using terraform code.

The terraform code for vpc and security group creation is written in modules, for the reusablity of terraform code.
