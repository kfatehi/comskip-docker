# Docker container for comskip
#
# This file is part of comskip-docker
# https://github.com/mgafner/comskip-docker
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this file.  If not, see <http://www.gnu.org/licenses/>.
#
FROM ubuntu:22.04 AS base
ARG DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      autoconf \
      build-essential \
      ffmpeg \ 
      git \
      libargtable2-dev \
      libavcodec-dev  \
      libavformat-dev \
      libavutil-dev \
      libsdl1.2-dev \
      libtool-bin \
      python3 \
      vim

RUN apt-get install -y libswscale-dev

FROM base AS comskip
#
# Clone comskip
WORKDIR /opt
RUN git clone --depth=1 https://github.com/erikkaashoek/Comskip comskip
WORKDIR /opt/comskip
RUN ./autogen.sh
RUN ./configure
RUN make -j$(nproc)

FROM comskip as comchap
#
# Clone comchap/comcut
WORKDIR /opt
RUN git clone --depth=1 https://github.com/BrettSheleski/comchap.git

FROM comchap as system
#
# link commands to user bin
RUN ln -s /opt/comskip/comskip /usr/bin/comskip
RUN ln -s /opt/comchap/comchap /usr/bin/comchap
RUN ln -s /opt/comchap/comcut /usr/bin/comcut

WORKDIR /root
ADD ./comskip.ini .comskip.ini
