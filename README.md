To add a Jenkins port to your AWS EC2 instance, you need to modify the inbound rules of the associated security group. Here's how you can do it: 

1.	Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/.
2.	Navigate to the "Instances" section and select the EC2 instance running Jenkins.
3.	Note the security group associated with your EC2 instance. You can find this information under the "Description" tab of the instance details.
4.	Go to the "Security Groups" section in the EC2 console.
5.	Locate the security group identified in step 3 and click on its name to open its details.
6.	In the "Inbound Rules" tab, click on the "Edit inbound rules" button.
7.	Click on "Add rule" to create a new inbound rule.
8.	Configure the rule by selecting the following:
	•	Type: Custom TCP
	•	Port Range: Enter the port number used by Jenkins (default is 8080)
	•	Source: Choose "Custom" and enter the IP range or specific IP address from where you want to allow access to Jenkins. You can specify your local machine's IP address or IP range (e.g., 0.0.0.0/0) for open access, but this is not recommended for security reasons.
9.	Click on the "Save rules" button to apply the changes.
After following these steps, the Jenkins port should be accessible from the specified IP address or IP range. Make sure to use the public IP or DNS name of your EC2 instance, along with the Jenkins port, to access the Jenkins server remotely.
Remember to consider security best practices, such as using secure access methods like VPN or SSH tunneling, and implementing authentication and access controls within Jenkins to protect your server from unauthorized access.


# Jenkins Install 

#!/bin/bash
# vi: ft=bash

echo "# $(date) Installation is starting."

# Uncomment the following line if you are using this script
# as user data for an EC2 instance on AWS.
# Output from the installation will be written to /var/log/user-data.log
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "# $(date) Instatll jenkins key and package configuration..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# install java, nginx, and jenkins
echo "# $(date) Install Java 11, NGINX, and Jenkins..."
apt update
apt-get -y upgrade

apt-get -y install \
    openjdk-11-jdk \
    nginx \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

apt-get -y install jenkins

# configure jenkins
echo "# $(date) Configure Jenkins..."

## skip the installation wizard at startup
echo "# $(date) Skip the installation wizard on first boot..."
echo "JAVA_ARGS=\"-Djenkins.install.runSetupWizard=false\"" >> /etc/default/jenkins

## download the list of plugins
echo "# $(date) Download the list of plugins..."
wget https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json

## get the suggested plugins
echo "# $(date) Use the keyword 'suggest' to find the suggested plugins in the list..."
grep suggest platform-plugins.json | cut -d\" -f 4 | tee suggested-plugins.txt

## download the plugin installation tool
echo "# $(date) Download the plugin installation tool"
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.3/jenkins-plugin-manager-2.12.3.jar

## run the plugin installation tool
echo "# $(date) Run the plugin installation tool..."
/usr/bin/java -jar ./jenkins-plugin-manager-2.12.3.jar \
	--verbose \
    --plugin-download-directory=/var/lib/jenkins/plugins \
    --plugin-file=./suggested-plugins.txt >> /var/log/plugin-installation.log

## because the plugin installation tool runs as root, ownership on
## the plugin dir needs to be changed back to jenkins:jenkins
## otherwise, jenkins won't be able to install the plugins
echo "# $(date) Update the permissions on the plugins directory..."
chown -R jenkins:jenkins /var/lib/jenkins/plugins

# configure nginx
echo "# $(date) Configure NGINX..."
unlink /etc/nginx/sites-enabled/default

tee /etc/nginx/conf.d/jenkins.conf <<EOF
upstream jenkins {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80  default_server;
    location / {
        proxy_pass http://jenkins;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

echo "# $(date) Reload NGINX to pick up the new configuration..."
systemctl reload nginx

# install docker
echo "# $(date) Install docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt-get -y install docker-ce docker-ce-cli containerd.io
docker run hello-world

systemctl enable docker.service
systemctl enable containerd.service

usermod -aG docker ubuntu
usermod -aG docker jenkins

echo "# $(date) Restart Jenkins..."
systemctl restart jenkins

echo "# $(date) Copy the initial admin password to the root user's home directory..."
cp /var/lib/jenkins/secrets/initialAdminPassword ~

clear
echo "Installation is complete."

echo "# Open the URL for this server in a browser and log in with the following credentials:"
echo
echo
echo "    Username: admin"
echo "    Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo
echo
