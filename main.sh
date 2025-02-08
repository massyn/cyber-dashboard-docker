#!/bin/sh

wait_until_time() {
    target_time="$1"
    echo "$(date '+%H%M') - waiting until $target_time....."
    while [ "$(date '+%H%M')" -ne "$target_time" ]; do
        sleep 10
    done
}

cd cyber-dashboard-flask

if [ ! -z "$AWS_S3_BUCKET" ]; then
    aws s3 cp $AWS_S3_BUCKET/summary.parquet data/summary.parquet 
    aws s3 cp $AWS_S3_BUCKET/detail.parquet data/detail.parquet 
    aws s3 cp $AWS_S3_BUCKET/config.yml server/config.yml
fi

service nginx stop
cp amazon_linux/nginx.conf /etc/nginx/sites-available/default
service nginx start

cd server
#gunicorn -w 4 -b 0.0.0.0:8000 app:server &
python app.py &
cd ../..

# == start the data collection
cd cyber-metrics
while true; do
    cd 01-collectors
    python wrapper.py
    cd ..

    cd 02-metrics
    python metrics.py
    cd ..

    cd ../cyber-dashboard-flask/server
    python api.py -load ../../cyber-metrics/data/detail.parquet

    # once the API has been uploaded, store the data files for later use
    if [ ! -z "$AWS_S3_BUCKET" ]; then
        aws s3 cp ../data/summary.parquet $AWS_S3_BUCKET/summary.parquet
        aws s3 cp ../data/detail.parquet $AWS_S3_BUCKET/detail.parquet
        aws s3 cp ../server/config.yml $AWS_S3_BUCKET/config.yml
    fi

    cd ../../cyber-metrics

    wait_until_time "000"
done


