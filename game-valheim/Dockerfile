ARG UPSTREAM_TAG=latest
FROM chrisbraucker/aarch64-gameservers:${UPSTREAM_TAG}

ARG DATA_DIR=/data
RUN apt-get update \
 && apt-get install --yes \
        libatomic1:armhf libpulse0:armhf libpulse-dev:armhf \
 && mkdir -p /root/.config/unity3d/IronGate/ \
 && ln -s /root/.config/unity3d/IronGate/Valheim ${DATA_DIR}

VOLUME [ "${DATA_DIR}" ]
VOLUME [ "/server" ]

COPY entrypoint.sh /
WORKDIR /server

CMD [ "/entrypoint.sh" ]
