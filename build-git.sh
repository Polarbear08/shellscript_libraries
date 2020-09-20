#!/bin/bash

GIT_VERSION=${1:-2.28.0}
GIT_DIR=git-${GIT_VERSION}
GIT_TAR=${GIT_DIR}.tar.gz

dnf -y update
dnf -y install tar gcc make autoconf curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel perl-ExtUtils-MakeMaker
curl -LkvOf https://mirrors.edge.kernel.org/pub/software/scm/git/${GIT_TAR}
tar xvf ${GIT_TAR}
cd ${GIT_DIR}
make prefix=/usr/local all
make prefix=/usr/local install
cd -
rm -rf ${GIT_DIR} ${GIT_TAR}

git --version
