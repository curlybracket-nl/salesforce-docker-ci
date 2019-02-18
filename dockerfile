FROM alpine:3.7 
MAINTAINER Peter van Gulik <peter@curlybracket.nl>

# Add packages
RUN apk --no-cache add \ 
    bash \
    openssh \
    git \
    openjdk8 \
    nodejs \
    curl \ 
    wget \
    && apk add apache-ant --no-cache --update-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    --allow-untrusted

# Copy build files
COPY build /build/

# Setup Ant
ENV ANT_HOME=/usr/share/java/apache-ant \
    PATH=$PATH:$ANT_HOME/bin

# Download SFDX
RUN mkdir -p /sfdx \
    && curl -SL https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz | tar -xJC /sfdx --strip-components 1 \
    && ln -sf /usr/bin/node /sfdx/bin/node \
    && /sfdx/install \
    && rm -rf /sfdx

# EOF