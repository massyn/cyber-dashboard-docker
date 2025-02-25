# cyber-dashboard-docker
A self-contained docker image with all the cyber metrics components wrapped up together

## Quick start

### Start your own basic instance

This instance will boot up a dashboard, ready to accept calls via the API.

```bash
$ docker run -p 443:443 \
    -d massyn/cyber-dashboard:main
```

### Start an instance with AWS S3 backed storage

```bash
$ docker run -p 443:443 \
    -e AWS_ACCESS_KEY_ID="AKIAxxxxxxx" \
    -e AWS_SECRET_ACCESS_KEY="xxxxxx" \
    -e AWS_S3_BUCKET="s3://MYBUCKETNAME/repo" \
    -d massyn/cyber-dashboard:main
```

### Start an instance and start collecting data from Crowdstrike

```bash
$ docker run -p 443:443 \
    -e FALCON_CLIENT_ID="xxxx" \
    -e FALCON_SECRET="xxxx" \
    -d massyn/cyber-dashboard:main
```

### Start an instance and start collecting data from Crowdstrike with S3 backed storage

```bash
$ docker run -p 443:443 \
    -e FALCON_CLIENT_ID="xxxx" \
    -e FALCON_SECRET="xxxx" \
    -e AWS_ACCESS_KEY_ID="AKIAxxxxxxx" \
    -e AWS_SECRET_ACCESS_KEY="xxxxxx" \
    -e AWS_S3_BUCKET="s3://MYBUCKETNAME/repo" \
    -d massyn/cyber-dashboard:main
```

## Build your own instance

The `install.sh` script can be used to build a server.  

### Ubuntu

```bash
$ git clone https://github.com/massyn/cyber-dashboard-docker
$ cd cyber-dashboard-docker
$ sh install.sh
```

### Amazon Linux

```bash
yum install git -y
git clone https://github.com/massyn/cyber-dashboard-docker
cd cyber-dashboard-docker
sh install.sh
```
