FROM debian:11.3-slim as dependencies

RUN dpkg --add-architecture armhf \
 && apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y \
      libsdl2-2.0-0 libsdl2-dev \
      libc6 libstdc++6 libncurses6 \
      libc6:armhf libstdc++6:armhf libncurses6:armhf


FROM dependencies as builder

WORKDIR /src
RUN apt-get install -y \
      git build-essential cmake \
      gcc-10 gcc-10 g++-10 cpp-10 gcc-10-arm-linux-gnueabihf \
      python3 curl \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
                        --slave /usr/bin/g++ g++ /usr/bin/g++-10 \
                        --slave /usr/bin/gcov gcov /usr/bin/gcov-10 \
                        --slave /usr/bin/arm-linux-gnueabihf-gcc arm-linux-gnueabihf-gcc /usr/bin/arm-linux-gnueabihf-gcc-10

# we download steamcmd with all other deps since it auto-updates
RUN git clone https://github.com/ptitSeb/box86 \
 && git clone https://github.com/ptitSeb/box64 \
 && curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o steamcmd.tar.gz \
 && mkdir -p steamcmd/ \
 && tar xvf steamcmd.tar.gz -C steamcmd/

ARG NUMTHREADS
# Defined by the architectures specified in CMakeLists.txt
ARG BUILDARCH

WORKDIR /src/box86/build
COPY CMakeLists86.txt ../CMakeLists.txt
RUN cmake .. -D${BUILDARCH:-RPI4ARM64}=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j${NUMTHREADS:-$(nproc)} \
 && sed -i \
      -e 's/CPACK_INSTALL_PREFIX/CPACK_PACKAGING_INSTALL_PREFIX/g' \
    CPackConfig.cmake \
 && make package

WORKDIR /src/box64/build
COPY CMakeLists64.txt ../CMakeLists.txt
RUN cmake .. -D${BUILDARCH:-RPI4ARM64}=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j${NUMTHREADS:-$(nproc)} \
 && sed -i \
      -e '/CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA/d' \
      -e 's/CPACK_INSTALL_PREFIX/CPACK_PACKAGING_INSTALL_PREFIX/g' \
    CPackConfig.cmake \
 && make package


FROM dependencies

WORKDIR /tmp
COPY --from=builder /src/box64/build/box64.deb /src/box86/build/box86.deb ./
RUN dpkg -i *.deb \
 && rm -rf *

WORKDIR /steamcmd
COPY --from=builder --chown=root:root /src/steamcmd .
ENV BOX86_DYNAREC "0"
ENV DEBUGGER "/usr/local/bin/box86"
CMD [ "/steamcmd/steamcmd.sh" ]
