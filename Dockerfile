FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget ca-certificates jq iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/java/8 && curl -sL "https://api.adoptium.net/v3/binary/latest/8/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/8 --strip-components=1 && rm /tmp/j.tar.gz
RUN mkdir -p /opt/java/11 && curl -sL "https://api.adoptium.net/v3/binary/latest/11/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/11 --strip-components=1 && rm /tmp/j.tar.gz
RUN mkdir -p /opt/java/17 && curl -sL "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/17 --strip-components=1 && rm /tmp/j.tar.gz
RUN mkdir -p /opt/java/21 && curl -sL "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/21 --strip-components=1 && rm /tmp/j.tar.gz
RUN mkdir -p /opt/java/24 && curl -sL "https://api.adoptium.net/v3/binary/latest/24/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/24 --strip-components=1 && rm /tmp/j.tar.gz
RUN mkdir -p /opt/java/25 && curl -sL "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jre/hotspot/normal/eclipse?project=jdk" -o /tmp/j.tar.gz && tar -xzf /tmp/j.tar.gz -C /opt/java/25 --strip-components=1 && rm /tmp/j.tar.gz

COPY java-wrapper.sh /usr/local/bin/java
RUN chmod +x /usr/local/bin/java

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN groupadd -g 995 container && useradd -u 999 -g 995 -m -d /home/container -s /bin/bash container
WORKDIR /home/container
ENTRYPOINT ["/entrypoint.sh"]
