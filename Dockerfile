FROM python:3

WORKDIR /python-docker

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install nginx -y

RUN git clone https://github.com/massyn/cyber-dashboard-flask
RUN git clone https://github.com/massyn/cyber-metrics
RUN pip install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
RUN pip install --no-cache-dir -r cyber-metrics/requirements.txt

COPY nginx.conf /etc/nginx/sites-enabled/default

RUN echo "Docker built on $(date)" >> cyber-dashboard-flask/server/about.md

COPY main.sh .
RUN chmod +x main.sh

EXPOSE 80

CMD [ "sh" , "./main.sh"]