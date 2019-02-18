FROM alpine:3.7 
MAINTAINER Peter van Gulik <peter@curlybracket.nl>

# Add packages
RUN apk --no-cache add \ 
    bash \
    openssh \
	git \
	openjdk8 \
	nodejs \
	&& apk add apache-ant --no-cache --update-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    --allow-untrusted
	
# Copy build files
COPY build /build/

# Setup Ant
ENV ANT_HOME=/usr/share/java/apache-ant \
    PATH=$PATH:$ANT_HOME/bin

# EOF