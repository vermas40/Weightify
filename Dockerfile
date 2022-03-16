FROM ubuntu:18.04

#this command ensures we do not get any pop ups and the timezone
#is Indian
ENV TZ="Asia/Kolkata" DEBIAN_FRONTEND="noninteractive"

#the below command adds a repo to apt and then install our specific
#version of R. The different versions of any package can be found using
#the command apt policy r-base (here trying to find versions of r-base package)
#also installing some developer tools like ssl and xml
RUN apt-get update && \
apt-get install -y \
software-properties-common \
libssl-dev \
libxml2-dev \
libcurl4-openssl-dev && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' && \
apt-get dist-upgrade -y && \
apt-get install -y --no-install-recommends \
r-base-core=4.0.5-1.1804.0 \
r-base-dev=4.0.5-1.1804.0 \
r-base-html=4.0.5-1.1804.0 \
r-doc-html=4.0.5-1.1804.0

#adding another repository to install binaries of r packages
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
apt-get update

#installing the binary packages
COPY . /app/
WORKDIR /app/
RUN cat app_requirements/binary_requirements.txt | xargs apt-get install -y -qq
#installing app dependencies
RUN Rscript app_requirements/pkg_inst.R

#defining an entrypoint for the dockerfile, this allows overloading and
#create different containers from same image
ENTRYPOINT ["Rscript"]
CMD ["app.R"]