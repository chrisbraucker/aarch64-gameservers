FROM debian as builder

WORKDIR /src

RUN dpkg --add-architecture armhf \
 && apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y \
      git build-essential cmake \
      libsdl2-2.0-0 libsdl2-dev \
      libc6 libstdc++6 \
      gcc-arm-linux-gnueabihf \
      libc6:armhf libncurses6:armhf libstdc++6:armhf \
      python3 curl

RUN git clone https://github.com/ptitSeb/box64 \
 && git clone https://github.com/ptitSeb/box86 \
 && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o steamcmd.tar.gz \
 && tar xvf steamcmd.tar.gz

WORKDIR /src/box86/build
RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j$(nproc) \
 && sed -i -e '/CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA/d' -e 's/CPACK_INSTALL_PREFIX/CPACK_PACKAGING_INSTALL_PREFIX/g' -e 's/set(CPACK_DEBIAN_FILE_NAME "box86.*\.deb")/set(CPACK_DEBIAN_FILE_NAME "box86.deb")/g' CPackConfig.cmake \
 && make package

WORKDIR /src/box64/build
RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j$(nproc) \
 && sed -i -e '/CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA/d' -e 's/CPACK_INSTALL_PREFIX/CPACK_PACKAGING_INSTALL_PREFIX/g' -e 's/set(CPACK_DEBIAN_FILE_NAME "box64.*\.deb")/set(CPACK_DEBIAN_FILE_NAME "box64.deb")/g' CPackConfig.cmake \
 && make package

FROM debian

WORKDIR /tmp

RUN dpkg --add-architecture armhf \
 && apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y \
      libsdl2-2.0-0 libsdl2-dev \
      libc6 libstdc++6 \
      libc6:armhf libstdc++6:armhf libncurses5:armhf libncurses6:armhf

COPY --from=builder /src/box64/build/box64.deb /src/box86/build/box86.deb ./
RUN dpkg -i *.deb \
 && rm -rf *

WORKDIR /steamcmd
COPY --from=builder --chown=root:root /src/steamcmd .
ENV BOX86_DYNAREC "0"
ENV DEBUGGER "/usr/local/bin/box86"
CMD [ "/steamcmd/steamcmd.sh" ]
