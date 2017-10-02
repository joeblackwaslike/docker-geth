#!/bin/bash -l

set -e


# Use local cache proxy if it can be reached, else nothing.
eval $(detect-proxy enable)

build::user::create $USER

log::m-info "Installing dependencies ..."
apt-get update -qq
apt-get install -yqq ca-certificates curl jq


log::m-info "Installing go-ethereum & tools ..."
GETH_DOWNLOAD_URL=https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-${GETH_VERSION}-${GETH_COMMIT}.tar.gz
gpg --recv-key A61A13569BA28146

tmp_dir=$(mktemp -d)
pushd $tmp_dir
curl -L -O $GETH_DOWNLOAD_URL && \
    gpg --no-tty --verify <(curl -s ${GETH_DOWNLOAD_URL}.asc) geth-alltools-*.tar.gz && \
    [[ $(md5sum geth-alltools-*.tar.gz | awk '{print $1}') == $GETH_MD5SUM ]] && \
    tar xzvf geth-alltools-*.tar.gz --strip-components=1 -C . && \
    chown -R root:root . && \
    chmod -R 0755 . && \
    rm -f *.tar.gz && \
    mv * /usr/local/bin && \
    popd && \
    rm -rf $tmp_dir

mkdir -p ~/.ethereum


log::m-info "Installing solc ..."
curl -sL -O https://github.com/ethereum/solidity/releases/download/v${SOLIDITY_VERSION}/solc-static-linux && \
    [[ $(md5sum solc-static-linux | awk '{print $1}') == $SOLIDITY_MD5SUM ]] && \
    mv solc-static-linux solc && \
    chown root:root solc && \
    chmod 0755 solc && \
    mv solc /usr/local/bin


log::m-info "Purging unnecessary packages ..."
apt-get purge -y --auto-remove ca-certificates


log::m-info "Cleaning up ..."
apt-clean --aggressive


# if applicable, clean up after detect-proxy enable
eval $(detect-proxy disable)

rm -r -- "$0"
