# DevOps

# Identity and Access Management

[https://techhub-aws-2510.signin.aws.amazon.com/console](https://techhub-aws-2510.signin.aws.amazon.com/console)

IAM USer: TechHubJimmy

Password: Anshumi+AWS@2023

Root account created by default, shouldn’t be used or shared
• Users are people within your organization, and can be grouped
• Groups only contain users, not other groups
• Users don’t have to belong to a group, and user can belong to multiple groups

IAM: Permissions
• Users or Groups can be assigned JSON documents called policies
• These policies define the permissions of the users
• In AWS you apply the least privilege principle: don’t give more permissions than a user needs

Roles:

- Create the role for the instance you have created
- Assign the relevant permission to the role

Security Tools in the IAM. 

- IAM Credentials Report (Account Level)
- IAM Access Advisor(User Level)

---------------------------------------------------------------------------------------------------------------
- Web Setup Script:

#!/bin/bash
sudo yum install -y httpd
sudo yum install -y wget
sudo yum install -y unzip

sudo systemctl start httpd
sudo systemctl enable httpd

cd/tmp/

wget https://www.tooplate.com/zip-templates/2108_dashboard.zip
unzip 2108_dashboard.zip

cp -r 2108_dashboard/* /var/www/html/
sudo systemctl res

---------------------------------------------------------------------------------------------------------------

- Network & Security
    - [Security Groups](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#SecurityGroups:)
    - [Elastic IPs](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Addresses:)
    - [Placement Groups](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#PlacementGroups:)
    
    Cluster—clusters instances into a low-latency  group in a single Availability Zone
    • Spread—spreads instances across underlying hardware (max 7 instances per
    group per AZ)
    • Partition—spreads instances across many different partitions (which rely on
    different sets of racks) within an AZ. Scales to 100s of EC2 instances per group
    (Hadoop, Cassandra, Kafka)
    
    - [Key Pairs](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#KeyPairs:)
    - [Network Interfaces](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#NIC:)
    
- Elastic Block Store
- [Volumes](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Volumes:)

---------------------------------------------------------------------------------------------------------------

Lifecycle Manager

	 20  ls
   21  fdisk -l
   22  df -h
   23  fdisk /dev/xvdf
   24  fdisk -l
   25  mkfs.ext4 /dev/xvdf1
   26  ls images/
   27  mkdir /tmp/img-backups
   28  mv images/* /tmp/img-backups/
   29  ls
   30  cd
   31  mount /dev/xvdf1 /var/www/html/images/
   32  df -h
   33  vi /etc/fstabb
   34  vi /etc/fstab
   35  mount -a
   36  df -h
   37  mv /tmp/img-backups/* /var/www/html/images/
   38  systemctl restart httpd
   39  ls
   40  umount /var/www/html/images
   41  df -h
   42  lsof /var/www/html/images
   43  mount -a
   44  systemctl restart httpd
   45  yum install lsof -y
   46  lsof /var/www/html/images
   47  history
   
   ---------------------------------------------------------------------------------------------------------------
