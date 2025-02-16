#!/bin/sh

apt-get update
apt-get upgrade -y

apt-get install unzip -y
apt-get install python3 python3-pip -y
apt-get install python3.12-venv -y
apt-get install nginx -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

python3 -m venv x
. x/bin/activate

git clone https://github.com/massyn/cyber-dashboard-flask
git clone https://github.com/massyn/cyber-metrics

pip3 install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
pip3 install --no-cache-dir -r cyber-metrics/requirements.txt

cp nginx.conf /etc/nginx/sites-enabled/default

systemctl stop nginx
systemctl start nginx
systemctl enable nginx
