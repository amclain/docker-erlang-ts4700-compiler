# Cross Compiling Erlang
# http://www.erlang.org/doc/installation_guide/INSTALL-CROSS.html

FROM amclain/crosstool-ng-ts4700
MAINTAINER Alex McLain <alex@alexmclain.com>

ENV ERLANG otp_src_17.4

WORKDIR /opt

# Download Erlang
RUN wget http://www.erlang.org/download/${ERLANG}.tar.gz
RUN tar -xzf ${ERLANG}.tar.gz && rm ${ERLANG}.tar.gz

# Install system packages
RUN apt-get -qq update
RUN apt-get -y dist-upgrade
RUN apt-get -y install libssl-dev
RUN apt-get -y install xsltproc
RUN apt-get -y install libxml2-utils

# Cross-compile ncurses
ENV NCURSES ncurses-5.9
RUN wget https://ftp.gnu.org/gnu/ncurses/${NCURSES}.tar.gz
RUN tar -xzf ${NCURSES}.tar.gz && rm ${NCURSES}.tar.gz

WORKDIR ${NCURSES}
RUN ./configure --host arm-unknown-linux-gnueabi --build x86_64-unknown-linux-gnu
RUN make
WORKDIR ..

# Cross-compile libssl
ENV LIBSSL openssl-1.0.2a
RUN wget https://www.openssl.org/source/${LIBSSL}.tar.gz
RUN tar -xzf ${LIBSSL}.tar.gz && rm ${LIBSSL}.tar.gz

WORKDIR ${LIBSSL}
RUN ./config --host arm-unknown-linux-gnueabi --build x86_64-unknown-linux-gnu
RUN make
WORKDIR ..

# # Bootstrap Erlang
WORKDIR ${ERLANG}
RUN ./configure --enable-bootstrap-only
RUN make

# Cross-compile Erlang
# RUN ./erts/autoconf/config.guess
RUN ./configure --host arm-unknown-linux-gnueabi --build x86_64-unknown-linux-gnu erl_xcomp_sysroot="/opt/crosstool-ng/x-tools/${TOOLCHAIN}/${TOOLCHAIN}/sysroot" CFLAGS="-I/opt/${NCURSES}/include" LDFLAGS="-L/opt/${NCURSES}/lib"
RUN make
# RUN make install
WORKDIR ..

VOLUME /tmp/build/erlang
