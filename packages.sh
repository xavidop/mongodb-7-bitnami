#!/bin/bash
set -e
export PACKAGE=gosu
export TARGET_DIR=common
export VERSION=1.14.0
export REF=1.14
export CGO_ENABLED=0 
rm -rf ${PACKAGE} || true
mkdir -p ${PACKAGE}
git clone -b "${REF}" https://github.com/tianon/gosu ${PACKAGE}
pushd ${PACKAGE}
go mod download
go build -v -ldflags '-d -s -w' .
mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
mkdir -p /opt/bitnami/${TARGET_DIR}/bin
cp -f LICENSE /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/gosu
popd
rm -rf ${PACKAGE}


#!/bin/bash
set -e
export PACKAGE=render-template
export TARGET_DIR=common
export VERSION=1.0.7
export REF=v${VERSION}
export CGO_ENABLED=0 
rm -rf ${PACKAGE} || true
mkdir -p ${PACKAGE}
git clone -b "${REF}" https://github.com/bitnami/render-template ${PACKAGE}
pushd ${PACKAGE}
go mod download
go build -v -ldflags '-d -s -w' .
mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
mkdir -p /opt/bitnami/${TARGET_DIR}/bin
cp -f LICENSE.md /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/${PACKAGE}
popd
rm -rf ${PACKAGE}


#!/bin/bash
set -e
export PACKAGE=wait-for-port
export TARGET_DIR=common
export VERSION=1.0.8
export REF=v${VERSION}
export CGO_ENABLED=0 
rm -rf ${PACKAGE} || true
mkdir -p ${PACKAGE}
git clone -b "${REF}" https://github.com/bitnami/wait-for-port ${PACKAGE}
pushd ${PACKAGE}
go mod download
go build -v -ldflags '-d -s -w' .
mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
mkdir -p /opt/bitnami/${TARGET_DIR}/bin
cp -f LICENSE.md /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/${PACKAGE}
popd
rm -rf ${PACKAGE}