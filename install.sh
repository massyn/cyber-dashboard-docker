#!/bin/sh

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            "amzn")
                echo "amzn"
                return
                ;;
            "ubuntu")
                echo "ubuntu"
                return
                ;;
            *)
                echo "none"
                return
                ;;
        esac
    else
        echo "none"
        return
    fi
}
os_type=$(detect_os)
echo "Detected OS: $os_type"

# Install all basic packages
if [ "$os_type" = "amzn" ]; then
    yum update -y
    yum install git -y
    yum install nginx -y
    yum install unzip -y
    yum remove python3-requests -y
elif [ "$os_type" = "ubuntu" ]; then
    apt-get update
    apt-get upgrade -y

    apt-get install unzip -y
    apt-get install python3 python3-pip -y
    apt-get install python3.12-venv -y
    apt-get install nginx -y
else
    echo "OS not supported for automated updates."
    exit 1
fi

STARTPATH=$(pwd)

# You may want to install the AWS CLI (or any other Cloud provider's CLI at this point)
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

mkdir /usr/bin/dashboard
cd /usr/bin/dashboard

git clone https://github.com/massyn/cyber-dashboard-flask
git clone https://github.com/massyn/cyber-metrics

# == We create a new python virtual environment to keep things clean
if [ "$os_type" = "amzn" ]; then
    python3 -m venv .venv
elif [ "$os_type" = "ubuntu" ]; then
    python -m venv .venv
    
fi
. .venv/bin/activate
echo where is python
type python

python -m pip install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
python -m pip install --no-cache-dir -r cyber-metrics/requirements.txt

# == Configure Flask service

if [ "$os_type" = "amzn" ]; then
    cp ${STARTPATH}/flaskapp.service /etc/systemd/system
    systemctl daemon-reload
    systemctl start flaskapp
    systemctl enable flaskapp
elif [ "$os_type" = "ubuntu" ]; then
    echo TODO
fi

# == configure nginx
if [ -f /etc/nginx/sites-enabled/default ]; then
    cp ${STARTPATH}/nginx.conf /etc/nginx/sites-enabled/default
else
    cp ${STARTPATH}/nginx.conf /etc/nginx/conf.d/app.conf
fi

if [ "$os_type" = "amzn" ]; then
    systemctl stop nginx
    systemctl start nginx
    systemctl enable nginx
elif [ "$os_type" = "ubuntu" ]; then
    service nginx stop
    service nginx start
    if [ ! -f /etc/rc.local ]; then
        echo "#!/bin/sh" > /etc/rc.local
        chmod +x /etc/rc.local
    fi
    grep -q "service nginx start" /etc/rc.local || echo "service nginx start" >> /etc/rc.local
fi

