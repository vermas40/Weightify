FROM ubuntu:18.04

#this command ensures we do not get any pop ups and the timezone
#is Indian
ENV TZ="Asia/Kolkata" DEBIAN_FRONTEND="noninteractive"

#the below command adds a repo to apt and then install our specific
#version of R. The different versions of any package can be found using
#the command apt policy r-base (here trying to find versions of r-base package)
RUN apt-get update && \
apt-get install -y software-properties-common && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' && \
apt-get dist-upgrade && \
apt-get install -y --no-install-recommends \
r-base-core=4.0.5-1.1804.0 \
r-base-html=4.0.5-1.1804.0 \
r-doc-html=4.0.5-1.1804.0

COPY . /app/
WORKDIR /app/

#installing app dependencies
RUN Rscript pkg_inst.R