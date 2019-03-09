FROM ubuntu:18.04
COPY hdd.img /
COPY snapshot.img /
COPY entrypoint.sh /
RUN apt update && \
  apt -y upgrade && \
  apt -y install xvfb && \
  apt -y install x11-utils && \
  apt -y install x11vnc && \
  apt -y install qemu && \
  chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

