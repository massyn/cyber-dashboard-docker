#!/bin/sh

# Amazon Linux install script

yum install git -y
yum install nginx -y
yum install unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

yum remove python3-requests -y

git clone https://github.com/massyn/cyber-dashboard-flask
git clone https://github.com/massyn/cyber-metrics

# == install the main app
python -m pip install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
python -m pip install --no-cache-dir -r cyber-metrics/requirements.txt

if [ -f /etc/nginx/sites-enabled/default ]; then
    cp nginx.conf /etc/nginx/sites-enabled/default
else
    cp nginx.conf /etc/nginx/conf.d/app.conf
fi

echo "Using systemctl to manage nginx..."
systemctl stop nginx
systemctl start nginx
systemctl enable nginx

# elif command_exists service; then
#     echo "Using service to manage nginx..."
#     service nginx stop
#     service nginx start
#     if [ ! -f /etc/rc.local ]; then
#         echo "#!/bin/sh" > /etc/rc.local
#         chmod +x /etc/rc.local
#     fi
#     grep -q "service nginx start" /etc/rc.local || echo "service nginx start" >> /etc/rc.local
# else
#     echo "Neither systemctl nor service found. Please start nginx manually."
#     exit 1
# fi