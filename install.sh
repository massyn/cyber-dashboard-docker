#!/bin/sh

# Install all basic packages
if command -v yum >/dev/null 2>&1; then
    yum install -y
    yum install git -y
    yum install nginx -y
    yum install unzip -y
    yum remove python3-requests -y
else
    apt-get update
    apt-get upgrade -y

    apt-get install unzip -y
    apt-get install python3 python3-pip -y
    apt-get install python3.12-venv -y
    apt-get install nginx -y
fi

# You may want to install the AWS CLI (or any other Cloud provider's CLI at this point)
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

# == We create a new python virtual environment to keep things clean
python -m venv .venv
. .venv/bin/activate

# == let's go grab our main application
git clone https://github.com/massyn/cyber-dashboard-flask
git clone https://github.com/massyn/cyber-metrics
python -m pip install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
python -m pip install --no-cache-dir -r cyber-metrics/requirements.txt

# == TODO configure the flask app

# == configure nginx
if [ -f /etc/nginx/sites-enabled/default ]; then
    cp nginx.conf /etc/nginx/sites-enabled/default
else
    cp nginx.conf /etc/nginx/conf.d/app.conf
fi

if command -v systemctl >/dev/null 2>&1; then
    echo "Using systemctl to manage nginx..."
    systemctl stop nginx
    systemctl start nginx
    systemctl enable nginx
else
    echo "Using service to manage nginx..."
    service nginx stop
    service nginx start
    if [ ! -f /etc/rc.local ]; then
        echo "#!/bin/sh" > /etc/rc.local
        chmod +x /etc/rc.local
    fi
    grep -q "service nginx start" /etc/rc.local || echo "service nginx start" >> /etc/rc.local
fi
