#!/bin/sh

check_qemu() {
  if [ -f /sys/class/dmi/id/product_name ]; then
    if grep -qi "qemu" /sys/class/dmi/id/product_name; then
      echo "Instance is running under QEMU (detected in DMI data)"
      return 0
    fi
  fi
}

wait_until_time() {
    target_time="$1"
    echo "$(date '+%H%M') - waiting until $target_time....."
    while [ "$(date '+%H%M')" -ne "$target_time" ]; do
        sleep 10
    done
}

cd /usr/bin/dashboard

. .venv/bin/activate

cd cyber-dashboard-flask

service nginx start

cd server
if check_qemu; then
    python app.py &
else
    gunicorn -w 4 -b 0.0.0.0:8080 app:server &
fi
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

    cd ../../cyber-metrics

    wait_until_time "000"
done


