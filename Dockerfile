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
wget \
python3-pip

RUN wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz && \
tar xzf Python-3.8.3.tgz && \
rm Python-3.8.3.tgz && \
cd Python-3.8.3 && \
./configure --enable-optimizations && \
make install

RUN apt-get remove --purge -y build-essential \
checkinstall

COPY requirements.txt \
helper_functions.py \
flask_api.py \
/wlp_api/

WORKDIR /wlp_api/

RUN pip3 install -r requirements.txt

CMD ["python3","flask_api.py"]