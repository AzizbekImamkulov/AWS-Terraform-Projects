#!/bin/bash
apt update -y
apt install apache2 -y

myip= $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Terraform Web Server</title>
  <style>
    body {
      background-color: #0f0f0f;
      color: #ffffff;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      text-align: center;
      padding: 50px;
    }
    .title {
      font-size: 2em;
      color: gold;
    }
    .version {
      color: magenta;
      font-weight: bold;
      margin-top: 20px;
    }
    .ip {
      color: #00ffff;
      font-size: 1.2em;
      margin-top: 10px;
    }
    .tagline {
      color: #f54242;
    }
  </style>
</head>
<body>
  <div class="title">
    🚀 Built by the Power of <span class="tagline">Terraform</span> v0.12
  </div>
  <div class="ip">
    🔒 Server Private IP: <span id="ip">$myip</span>
  </div>
  <div class="version">
    🌟 Version 3.0
  </div>
</body>
</html>
EOF


systemctl start httpd
systemctl enable httpd