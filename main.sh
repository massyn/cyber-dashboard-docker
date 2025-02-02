#!/bin/sh

cd cyber-dashboard-flask

service nginx stop
cp amazon_linux/nginx.conf /etc/nginx/sites-available/default
service nginx start

cd server
gunicorn -w 4 -b 0.0.0.0:8000 app:server


