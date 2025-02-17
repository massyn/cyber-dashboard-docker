FROM python:3

WORKDIR /python-docker

RUN apt-get update
RUN apt-get upgrade -y

COPY install.sh .
COPY nginx.conf .
RUN sh install.sh

RUN echo "Updated on $(date)" >> cyber-dashboard-flask/server/about.md

COPY main.sh .
RUN chmod +x main.sh

EXPOSE 80

CMD [ "sh" , "./main.sh"]