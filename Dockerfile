FROM alpine:3.9
MAINTAINER Peter van Gulik <peter@curlybracket.nl>

# Add packages
RUN apk --no-cache add \ 
    bash \
    openssh \
    git \
    openjdk8 \
    nodejs \
    npm \
    curl \ 
    wget \
    unzip \
    nss \
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

# Download Sonarscanner
RUN curl -SL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492.zip -o sonar.zip \
    && unzip sonar.zip \
    && mv sonar-scanner-3.3.0.1492 sonar-scanner \
    && ln -sf /sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner \
    && ln -sf /sonar-scanner/bin/sonar-scanner-debug /usr/bin/sonar-scanner-debug \
    && rm -rf sonar.zip

# Setup entry point to use umask 0000 and run bash
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod ugo+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# EOF