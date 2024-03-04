# DEPLOY REST-API 

EXPLANATION
* This project will be BUILDING a REST based API Application,
 with REST end points which will be able to STORE DATA into the Databae(RDS Instance-MySQL). This is a Python Flask application.

* We will be using a registered Domain to access our Rest-API service (WebApp) that is deployed into EC2 instance & this instance will be able to store data into our Database.

AWS SERVICE
*1 Route53: for managing Domain request 
*2 VPC and Subnet: For setting up our whole network + setting up Internet Gateway and Route Table and Load Balancer for EC2.
*3 RDS Instance: For storing our data in RDS that runs MySQL.
*4 Certificate Manager: managing SSL/TLS certificates, ensuring secure communication for your applications
*5 Elastic-Load-Balancer: To distributes incoming network traffic across multiple targets, such as in EC2, containers, and IP addresses, within one or more Availability Zone
*6 Target Group: To route traffic to registered targets, i.e instances, containers, IP addresses, or Lambda functions.


PROJECT IS DIVIDED INTO 3 GITHUB REPOsitories
*1st. Is our Python-based Flask APplication (https://www.youtube.com/watch?v=otQqd7GRVK0&ab_channel=RahulWagh)
*2nd. Is our Terraform & AWS (Our Infrastructure provisioning will be done with Terrform ) (https://github.com/rahulwagh/terraform-jenkins)
*3rd. Is our Jenkins where our CI-CD Pipeleines will be created. (https://github.com/rahulwagh/python-mysql-db-proj-1)



*STEP 1 - SETTING UP VPC - JENKINS
*1. Setting-Up VPC(Virtual Private Cloud). VPC will be our Virtual-Private-Data-Center used to setup all our components. We need a Public Subnet and a Private Subnet 
# Setup VPC
resource "aws_vpc" "dev_proj_1_vpc_eu_central_1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

#Why do we need a Public & Private Subnet 
- So that any resource that need access to internet wi;; reside in our Public Subnet. Example is REST-API (Our Python based Flask Application)
- Private Subnet: For resource that doesnt need access to Internet. Example is Databases(They can only be accesed from our Application). Whats does This means 
* This means that our Flask APplication in Public Subnet will be able to communicate to our Private Subnet where our Database is. FOR THIS TO HAPPEN?
* We also used 2 different availability zones.
- Our Jenkins reside in EU-WEST-1
- Our Application Infrastructure is in EU_Central-1
SUBNET-CODE:

# Setup public subnet
resource "aws_subnet" "dev_proj_1_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_central_1.id    
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "dev-proj-public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "dev_proj_1_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_central_1.id    # you have to make referenece to the VPC it should be created
  cidr_block        = element(var.cidr_private_subnet, count.index) # specifying the value of IP range
  availability_zone = element(var.eu_availability_zone, count.index)  #We specified availability zones for Jenkins

  tags = {
    Name = "dev-proj-private-subnet-${count.index + 1}"
  }
}

* WE DEFINED SOME VARIABLES OF IP RANGE for Publi & PrivateSubnet.
- Subnets were used to provide maximum Availablility.
-The Subnet resides within the VPC
CODE:

bucket_name = "devnecs"

vpc_cidr             = "11.0.0.0/16"
vpc_name             = "dev-proj-jenkins-eu-west-vpc-1"
cidr_public_subnet   = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet  = ["11.0.3.0/24", "11.0.4.0/24"]
eu_availability_zone = ["eu-west-1a", "eu-west-1b"]

public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4lbZR1cVrBiO61M7tmcL+H4fonxwKUxjecwkfieCup17R+5+rJfLZu4/c4/4zZCvhG68BcZNmndULsEV/DIiHWIye8Na2P9Pmhbu9PhuAo6xaclIsSXv/h/GL+TXZcobB1I95YubxLKundQYe0Q7+ZbIpva0vE88GxTE5pyJhSH801WjAWPQlEieVXr4rXLFxY2oNN/v18/MwLkRB0oKLexgq9rB4CvaF81WIjPtAJUh7oCg+20Oyjz9+F6jTggNxlvf8OWqMUhYYI/MjpaB5thG3LHlzZuc2I3zvTwJwWp8L6JTOE1OExtq5es1PDGpzt9QOQfSfdtoaufa1HZkoYV5sXwRHpD2pAPkoUeTsa5/lseZxsE9n/SMZy9Hn0K/hstujptHk9my/Z2CQgaR0jX1QhCU9BvEU8OPVJx6ki0ifTfsV2a/jhzvZK+Oib/3uKvARaXICHbMsA8Tzf9R9rQ0+6ADvnf7FOOTHwmlXO2vfZwi9kw0P/5KZgiTMoNU= User@DevOps"
ec2_ami_id = "ami-0694d931cee176e7d"  # You can copy a new AMI ID  when you do as if you want to launch and EC2 instance. it's below the No of Instance
# To get youor ssh key
RUN: cat /c/Users/User/.ssh/id_rsa.pub # OR Generate a new one with (ssh-keygen)
* We also wrote a code for our CREDENTIALS (Access Keys)
- This will give access to Terraform for provisioning
#CODE:
provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["c:\Users\User\.aws\credentials"]
}

# To locate your credentials
- Create your system PATH from the above - #"C:\Users\User\.aws\credentials" 
- Make sure you (Create Access Keys) & IAM User if you dont already have
RUN: aws configure # set all the access key ID
Then
RUN: cd   # Go to default home directory
RUN: ls -l .aws
User@DevOps MINGW64 ~
$ cat .aws/credentials
[default]
aws_access_key_id = AKIAUN6QJRV4T3AH4MWB
aws_secret_access_key = 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


* Create S3 Bucket in AWS
- Copy the bucket name and paste 
* Make Changes to the Backend
terraform {
  backend "s3" {
    bucket = "devnecs"
    key    = "devops-project-1/jenkins/terraform.tfstate"
    region = "eu-west-1"
  }
}

* Create S3 Bucket in AWS
- Copy the bucket name and paste 
RUN: aws sts get-caller-identity 


STEP 2
- Initialize Terraform in (terraform-jenkins) directory
RUN: terraform init

RUN: terraform plan
# After checking the plan with no errors RUN APPLY
RUN: terraform apply  # This will provision all the network, VPC, SUbnets etc that we need

# CREATING INTERNET GATEWAY 
* Internet Gateway in the PUBLIC SUBNET
- We have to create our INTENET GATEWAY in such away that resources within the subnet can access the internet as well as those outside can access resources on the public subnet thru the Internet 

# Setup Internet Gateway
resource "aws_internet_gateway" "dev_proj_1_public_internet_gateway" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  tags = {
    Name = "dev-proj-1-igw"
  }
}

* Route Table in the PUBLIC SUBNET
- For Public subnets that need internet access, route pointing to an Internet Gateway (IGW) is added to the routing table.
The IGW allows instances in the subnet to communicate with the internet.

- Route Table for Public Subnet will have the VPC ID, INTERNET GATEWAY ID and RESOURCE


* We have to create A-Record to re-direct our domain name with an EC2-IPv4 address.
- (# BUT instead of using EC2 Instance IP address; We will use a Load Balancer(ALB). It will route the )

* You have to manually create a Hosted Zone
- iamnecs.com will be use to create a hosted zone.
- ENter iamnecs into your Terraform code
After that, 
- You have to point your Domain Name to AWS Name Server

*STEP 3
(#LOGIN TO JENKINS & INSTALL PLUGINS)
* Install (Pipeline AWS Steps)