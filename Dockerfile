FROM python:3

WORKDIR /python-docker

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install nginx -y

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip
    
RUN git clone https://github.com/massyn/cyber-dashboard-flask
RUN git clone https://github.com/massyn/cyber-metrics

# == install the main app
RUN pip3 install --no-cache-dir -r cyber-dashboard-flask/requirements.txt
RUN pip3 install --no-cache-dir -r cyber-metrics/requirements.txt

COPY main.sh .
RUN chmod +x main.sh

EXPOSE 80

CMD [ "sh" , "./main.sh"]