#this version of r based on ubuntu
FROM rocker/r-apt:bionic

#adding the ubuntu PPA and some dev tools
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
apt-get update && \
apt-get install -y \
libxml2-dev \
libssl-dev

#installing most of the packages through binaries and rest
#through R itself
COPY . /app
WORKDIR /app
RUN cat app_requirements/binary_requirements.txt | xargs apt-get install -y -qq
#installing app dependencies
RUN Rscript app_requirements/pkg_inst.R

#defining an entrypoint for the dockerfile, this allows overloading and
#create different containers from same image
ENTRYPOINT ["Rscript"]
CMD ["app.R"]