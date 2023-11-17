FROM ubuntu:22.04

# from https://github.com/steamcmd/docker/blob/master/dockerfiles/ubuntu-22/Dockerfile
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture armhf \
 && apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y --no-install-recommends \
      software-properties-common \
      python3 ca-certificates curl locales \
      libsdl2-2.0-0 libsdl2-dev \
      libc6 libstdc++6 libncurses6 \
      libsdl2-2.0-0:armhf libc6:armhf libstdc++6:armhf libncurses6:armhf \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o steamcmd.tar.gz \
 && mkdir -p /steamcmd/ \
 && tar xvf steamcmd.tar.gz -C /steamcmd/ \
 && rm -rf steamcmd.tar.gz

COPY steamcmd /usr/local/bin/steamcmd

RUN chmod +x /usr/local/bin/steamcmd

RUN curl -fsSL https://raw.githubusercontent.com/FEX-Emu/FEX/main/Scripts/InstallFEX.py --output /tmp/InstallFEX.py \
 && sed -i -e '/subprocess.call(\["sudo", "-K"\])/s/^/#/' -e 's/"sudo", //g' /tmp/InstallFEX.py \
 && python3 /tmp/InstallFEX.py