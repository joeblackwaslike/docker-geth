#!/bin/bash -l

set -e

# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)


log::m-info "Installing essentials ..."
apt-get update
apt-get install -y \
    curl \
    ca-certificates \
    git


log::m-info "Installing dependencies ..."
apt-get install -y \
    gcc \
    libc6-dev \
    build-essential \
    cmake \
    libboost-all-dev


log::m-info "Installing golang ..."
pushd /tmp
    curl -sLO -O \
    https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz
    popd && rm -rf /tmp/go*
export PATH=/usr/local/go/bin:$PATH


log::m-info "Installing go-ethereum ..."
go get github.com/ethereum/go-ethereum
go install github.com/ethereum/go-ethereum/...
mv ~/go/bin/* /usr/local/bin/


log::m-info "Installing solidity ..."
pushd /tmp
    git clone -b $SOLC_VERSION --recursive https://github.com/ethereum/solidity.git
    cd solidity
        git submodule update --init --recursive
        mkdir build
        cd build
            cmake .. && make
            popd && rm -rf /tmp/solidity


log::m-info "Creating required directories and files ..."
mkdir -p $HOME/bin
touch /root/.ethereum.toml


log::m-info "Purging unnecessary packages ..."
apt-get purge -y --auto-remove \
    build-essential \
    git \
    make \
    cmake \
    gcc \
    g++ \
    libboost-all-dev \
    libstdc++-4.9-dev \
    libgcc-4.9-dev

log::m-info "Uninstalling golang ..."
rm -rf /usr/local/go ~/go

log::m-info "Cleaning up ..."
apt-clean --aggressive


# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
