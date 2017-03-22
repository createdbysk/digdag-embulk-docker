FROM python:2.7.13

# INSTALL JAVA BASED ON openjdk:8u121

# A few problems with compiling Java from source:
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#       really hairy.

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

ENV JAVA_VERSION 8u121
ENV JAVA_DEBIAN_VERSION 8u121-b13-1~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	&& rm -rf /var/lib/apt/lists/* \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# If you're reading this and have any feedback on how this image could be
#   improved, please open an issue or a pull request so we can discuss it!

# Use --build-arg with docker build command to override these values.
# For example,
# docker build . --build-arg DIGDAG_VERSION=latest \
#                --build-arg EMBULK_VERSION=latest
ARG DIGDAG_DOWNLOAD_SERVER=https://dl.digdag.io
ARG EMBULK_DOWNLOAD_SERVER=https://dl.bintray.com/embulk/maven
ARG DIGDAG_VERSION=0.9.3
ARG EMBULK_VERSION=0.8.16

COPY digdag.properties /etc/digdag.properties
COPY run-digdag.sh /home/digdag/run-digdag.sh
COPY GemFile /home/digdag/GemFile

RUN curl -o /usr/bin/digdag --create-dirs -L "$DIGDAG_DOWNLOAD_SERVER/digdag-$DIGDAG_VERSION" && \
    chmod +x /usr/bin/digdag

RUN curl  -o /usr/bin/embulk --create-dirs -L "$EMBULK_DOWNLOAD_SERVER/embulk-$EMBULK_VERSION.jar" && \
    chmod +x /usr/bin/embulk

RUN chmod +x /home/digdag/run-digdag.sh

RUN useradd -d /home/digdag -s /sbin/nologin -U digdag && \
    chown digdag /home/digdag

WORKDIR /home/digdag

USER digdag

# Install as the digdag user
RUN embulk gem install -g /home/digdag/GemFile

ENV CONFIG_FILE=/etc/digdag.properties
ENV ADDITIONAL_DIGDAG_CLI_PARAMETERS=

EXPOSE 65432 65433

CMD ["/bin/bash", "-c", "./run-digdag.sh $ADDITIONAL_DIGDAG_CLI_PARAMETERS"]
