#!/bin/sh

wait_until_time() {
    target_time="$1"
    echo "$(date '+%H%M') - waiting until $target_time....."
    while [ "$(date '+%H%M')" -ne "$target_time" ]; do
        sleep 10
    done
}

service nginx start

cd /usr/bin/dashboard
. .venv/bin/activate

cd /usr/bin/dashboard/cyber-dashboard-flask/server
gunicorn -w 4 -b 0.0.0.0:8080 app:server &

# == start the data collection
cd /usr/bin/dashboard/cyber-metrics
while true; do
    cd 01-collectors
    python wrapper.py
    cd ..

    cd 02-metrics
    python metrics.py
    cd ..

    cd ../cyber-dashboard-flask/server
    python api.py -load ../../cyber-metrics/data/detail.parquet

    cd ../../cyber-metrics

    wait_until_time "000"
done


