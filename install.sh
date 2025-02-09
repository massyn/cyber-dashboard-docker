#!/bin/sh

command_exists() {
    which "$1" >/dev/null 2>&1
}

install_package() {
    PACKAGE=$1

    if command_exists "$PACKAGE"; then
        echo "$PACKAGE is already installed."
        return 
    fi

    echo "Detecting package manager..."
    if command_exists yum; then
        echo "yum detected. Installing $PACKAGE..."
        yum update -y
        yum install "$PACKAGE" -y
    elif command_exists apt-get; then
        echo "apt-get detected. Installing $PACKAGE..."
        apt-get update -y
        apt-get install "$PACKAGE" -y
    else
        echo "No compatible package manager found. Please install $PACKAGE manually."
        exit 1
    fi

    echo "$PACKAGE installation complete."
}

# Check for python3
if command -v python3 >/dev/null 2>&1; then
    PYTHON=$(command -v python3)
elif command -v python >/dev/null 2>&1; then
    PYTHON=$(command -v python)
else
    echo "Error: Neither python3 nor python found on the system."
    exit 1
fi

# Run the function with the provided argument
install_package "git"
install_package "nginx"
install_package "unzip"
install_package "python3-pip"

curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip

if command_exists yum; then
    yum remove python3-requests -y
fi

git clone https://github.com/massyn/cyber-dashboard-flask
git clone https://github.com/massyn/cyber-metrics

# == install the main app
$PYTHON -m pip install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
$PYTHON -m pip install --no-cache-dir -r cyber-metrics/requirements.txt

if [ -f /etc/nginx/sites-enabled/default ]; then
    cp nginx.conf /etc/nginx/sites-enabled/default
else
    cp nginx.conf /etc/nginx/conf.d/app.conf
fi

if command_exists systemctl; then
    echo "Using systemctl to manage nginx..."
    systemctl stop nginx
    systemctl start nginx
    systemctl enable nginx
elif command_exists service; then
    echo "Using service to manage nginx..."
    service nginx stop
    service nginx start
    if [ ! -f /etc/rc.local ]; then
        echo "#!/bin/sh" > /etc/rc.local
        chmod +x /etc/rc.local
    fi
    grep -q "service nginx start" /etc/rc.local || echo "service nginx start" >> /etc/rc.local
else
    echo "Neither systemctl nor service found. Please start nginx manually."
    exit 1
fi