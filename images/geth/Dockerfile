FROM joeblackwaslike/debian:stretch

MAINTAINER Joe Black <me@joeblack.nyc>

ARG     GETH_VERSION
ARG     GETH_COMMIT
ARG     GETH_MD5SUM

ARG     SOLIDITY_VERSION
ARG     SOLIDITY_MD5SUM

ENV     GETH_VERSION ${GETH_VERSION:-1.6.7}
ENV     GETH_COMMIT ${GETH_COMMIT:-ab5646c5}
ENV     GETH_MD5SUM ${GETH_MD5SUM:-2a070065c2b4e12d6fbe294fa868f0ed}
ENV     SOLIDITY_VERSION ${SOLIDITY_VERSION:-0.4.16}
ENV     SOLIDITY_MD5SUM ${SOLIDITY_MD5SUM:-92d0132ac24436010c22383b161b4c7d}

LABEL   geth.version=$GETH_VERSION
LABEL   geth.commit=$GETH_COMMIT
LABEL   solidity.version=$SOLIDITY_VERSION

ENV     USER geth
ENV     HOME /opt/$USER

SHELL   ["/bin/bash", "-lc"]

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    entrypoint /
COPY    90-eth-common.sh /etc/profile.d/
COPY    geth-helper /usr/local/bin/
COPY    goss /goss

COPY    geth /usr/local/sbin/
COPY    geth-wrap /usr/local/bin/
COPY    swarm-wrap /usr/local/bin/

VOLUME  ["$HOME/.ethereum"]

# NetworkID's) 1: Mainnet  2:Morden (disused)  3:Ropsten (testnet)
ENV     GETH_NETWORK_ID 3
ENV     GETH_VERBOSITY 3
ENV     GETH_MINE false

# geth
EXPOSE  8545 8546 30303 30303/udp 30304/udp

# swarm
EXPOSE  8500 30399 30399/udp

ENTRYPOINT  ["/dumb-init", "--", "/entrypoint"]
CMD         ["geth-wrap"]

HEALTHCHECK --interval=15s --timeout=5s CMD goss -g /goss/goss.yaml validate
# HEALTHCHECK --interval=15s --timeout=5s CMD /root/bin/geth-helper node-is-healthy || exit 1
