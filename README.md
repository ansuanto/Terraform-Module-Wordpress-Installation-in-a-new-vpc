# Terraform-Module-Wordpress-Installation-in-a-new-vpc

To ensure the reusablity of code, we write the code in modules.

This repository is for creating infra and deploying Wordpress in it using terraform. Here I have created 1 VPC with 3 Subnets: 2 Private and 1 Public, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables via terraform.

There after we creates 3 instances - bastion,frontend and backend by terraform itself. Then Installed Wordpress on frontend and mariadb on backend instance. 
 
Here I am using 3 servers:

> 1.Bastion/jumpbox(public subnet)

> 2.Database(private subnet)

> 3.Webserver(public subnet)

We can only access frontend and backend instances by ssh to bastion/jumpbox.

After creating the infra, wordpress is installed using terraform code.

The terraform code for vpc and security group creation is written in modules, for the reusablity of terraform code.

Procedures to apply the code follows:

1.Initialize Terraform:

> terraform init

2.To reformat our Terraform configuration in the standard style, command used:

> terraform fmt

3.To check whether your configuration is valid, enter the following command:

> terraform validate

4.To review the configuration and verify that the resources that Terraform is going to create or update, we can use following command.

> terraform plan

We can make corrections to the configuration as necessary.

5.To apply the Terraform configuration, run following command and enter 'yes' at the prompt:

> terraform apply

or

> terraform apply -auto-approve

Terraform displays the "Apply complete!" message, which indicates the code is deployed
Finally, we will be able to see the wp installation page.
