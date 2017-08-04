FROM callforamerica/debian

MAINTAINER Joe Black <joeblack949@gmail.com>

ARG     GOLANG_VERSION
ARG     SOLC_VERSION

ENV     GOLANG_VERSION=${GOLANG_VERSION:-1.8.3}
ENV     SOLC_VERSION=${SOLC_VERSION:-v0.4.13}

LABEL   lang.golang.version=$GOLANG_VERSION
LABEL   compiler.solc.version=$SOLC_VERSION

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    entrypoint /
COPY    build/geth /usr/local/sbin/
COPY    build/geth-wrap /root/bin/
COPY    build/swarm-wrap /root/bin/
COPY    build/geth-helper /root/bin/

# NetworkID's) 1: Mainnet  2:Morden (disused)  3:Ropsten
ENV     GETH_NETWORK_ID 3
ENV     GETH_VERBOSITY 3
ENV     GETH_MINE false

# geth
EXPOSE  8545 8546 30303 30303/udp 30304

# swarm
EXPOSE  8500 30399 30399/udp

VOLUME  ["/root/.ethereum"]

SHELL       ["/bin/bash", "-lc"]

ENTRYPOINT  ["/dumb-init", "--", "/entrypoint"]
CMD         ["geth"]

HEALTHCHECK --interval=15s --timeout=5s \
    CMD /root/bin/geth-helper node-is-healthy || exit 1
