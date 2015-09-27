###
# swagger-ui-builder - https://github.com/wordnik/swagger-ui/
# Container for building the swagger-ui static site
#
# Build: docker build -t swagger-ui-builder .
# Run:   docker run -v $PWD/dist:/build/dist swagger-ui-builder
#
###

FROM    ubuntu:14.04
MAINTAINER dnephin@gmail.com

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt-get update && apt-get install -y git npm nodejs openjdk-7-jre && sudo apt-get install unzip
RUN     ln -s /usr/bin/nodejs /usr/local/bin/node
RUN     /bin/bash extract.sh

WORKDIR /build
ADD     package.json    /build/package.json
RUN     npm install
ADD     .   /build
VOLUME ["/build/dist/specs"]
CMD     ./node_modules/gulp/bin/gulp.js serve
