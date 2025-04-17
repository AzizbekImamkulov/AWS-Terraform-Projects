#!/bin/bash

# Update system and install Apache
yum -y update
yum -y install httpd

# Get the private IP of the instance
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a basic HTML page
cat <<EOF > /var/www/html/index.html
<html>
  <body bgcolor="black">
    <h2>
      <font color="gold">Build by Power of <font color="red">Terraform</font></font>
    </h2>
    <p><font color="green">Server PrivateIP: <font color="aqua">${PRIVATE_IP}</font></font></p>
    <p><font color="yellow"><b>Version 2.0</b></font></p>
  </body>
</html>
EOF

# Start and enable Apache service
systemctl start httpd
systemctl enable httpd
