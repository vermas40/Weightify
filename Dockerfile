FROM python:3.8.3-slim

#installing all the required packages for building Python 3.8.3
RUN apt-get update && \
apt-get install -y python3-pip

COPY requirements.txt \
helper_functions.py \
app.py \
/app/

WORKDIR /app/

RUN pip3 install -r requirements.txt

#host is being set on 0.0.0.0
#this makes the traffic to be bound to the local IP address
CMD ["flask","run", "--host", "0.0.0.0","--port","1234"]