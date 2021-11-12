FROM ubuntu:18.04

ENV TZ="Asia/Kolkata" DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y \
build-essential \
checkinstall \
libreadline-gplv2-dev \
libncursesw5-dev \
libssl-dev \
libsqlite3-dev \
tk-dev libgdbm-dev \
libc6-dev \
libbz2-dev \
liblzma-dev \
wget \
python3-pip \
nano

RUN wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz && \
tar xzf Python-3.8.3.tgz && \
rm Python-3.8.3.tgz && \
cd Python-3.8.3 && \
./configure --enable-optimizations && \
make install && \
cd .. && \
rm -rf Python-3.8.3

RUN apt-get remove --purge -y build-essential \
checkinstall

COPY requirements.txt \
helper_functions.py \
app.py \
/wlp_api/

WORKDIR /wlp_api/

RUN pip3 install -r requirements.txt

CMD ["flask","run", "--host", "0.0.0.0"]