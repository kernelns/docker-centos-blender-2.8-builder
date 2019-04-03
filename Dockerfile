FROM centos

LABEL maintainer="mattias.ohlsson@inprose.com"

ENV HOME /root
WORKDIR $HOME

RUN yum update -y && yum clean all

# Install packages
RUN yum -y install centos-release-scl epel-release \
 && yum -y install alsa-lib-devel autoconf automake bison cmake3 \
    devtoolset-7-gcc-c++ flex freetype-devel gcc git \
    jack-audio-connection-kit-devel libjpeg-turbo-devel libpng-devel libtool \
    libX11-devel libXcursor-devel libXi-devel libXinerama-devel \
    libXrandr-devel libXt-devel make mesa-libGLU-devel patch pcre-devel \
    pulseaudio-libs-devel python36 python-setuptools subversion tcl yasm \
    zlib-devel \
 && yum clean all

# Use cmake3
RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
    --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
    --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
    --family cmake

# Install NASM
RUN curl -O https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.gz \
 && tar xf nasm-*.tar.gz && cd nasm-*/ \
 && ./configure && make && make install \
 && cd && rm -rf $HOME/nasm-*

# Get the source
RUN mkdir $HOME/blender-git \
 && cd $HOME/blender-git \
 && git clone https://git.blender.org/blender.git \
 && cd $HOME/blender-git/blender \
 && git submodule update --init --recursive \
 && git submodule foreach git checkout master \
 && git submodule foreach git pull --rebase origin master

# Fix freetype 404
# build_files/build_environment/cmake/versions.cmake:
#   set(FREETYPE_VERSION 2.9.1)
#   set(FREETYPE_URI http://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz)
#   set(FREETYPE_HASH 3adb0e35d3c100c456357345ccfa8056)
RUN mkdir -p $HOME/blender-git/build_linux/deps/build/freetype/src/ \
 && cd $HOME/blender-git/build_linux/deps/build/freetype/src/ \
 && curl -O https://download-mirror.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz

COPY start /usr/bin/
RUN chmod +x /usr/bin/start
CMD ["scl", "enable", "devtoolset-7", "/usr/bin/start"]
