#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

yum install -y wget
yum install -y unzip 

cd /tmp/
wget https://www.tooplate.com/zip-templates/2108_dashboard.zip
unzip 2108_dashboard.zip

cp -r 2108_dashboard/* /var/www/html/
systemctl restart httpd
