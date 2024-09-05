# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM golang:1.22-bullseye AS golang-builder

RUN mkdir -p /opt/bitnami

ADD packages.sh /packages.sh
RUN chmod +x /packages.sh && \
    /packages.sh

FROM mikefarah/yq:4.43.1 AS yq

FROM docker.io/bitnami/minideb:bookworm

ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2024-09-04T12:31:44Z" \
      org.opencontainers.image.description="Application packaged by Broadcom, Inc." \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/mongodb/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="7.0.14-debian-12-r3" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/mongodb" \
      org.opencontainers.image.title="mongodb" \
      org.opencontainers.image.vendor="Broadcom, Inc." \
      org.opencontainers.image.version="7.0.14"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libbrotli1 libcom-err2 libcurl4 libffi8 libgcc-s1 libgmp10 libgnutls30 libgssapi-krb5-2 libhogweed6 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.5-0 libnettle8 libnghttp2-14 libp11-kit0 libpsl5 librtmp1 libsasl2-2 libssh2-1 libssl3 libtasn1-6 libunistring2 libzstd1 numactl procps zlib1g
RUN echo install global

COPY --from=golang-builder /opt/bitnami/ /opt/bitnami/ 
# refer : https://github.com/docker-library/mongo
# license : Apache-2.0 License
# https://github.com/docker-library/mongo/blob/master/LICENSE
ENV MONGO_MAJOR="7.0"

RUN install_packages gnupg curl wget

RUN set -ex; \
  curl -fsSL https://www.mongodb.org/static/pgp/server-${MONGO_MAJOR}.asc | \
  gpg -o /usr/share/keyrings/mongodb-server-${MONGO_MAJOR}.gpg \
  --dearmor

# Allow build-time overrides (eg. to build image with MongoDB Enterprise version)
# Options for MONGO_PACKAGE: mongodb-org OR mongodb-enterprise
# Options for MONGO_REPO: repo.mongodb.org OR repo.mongodb.com
# Example: docker build --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org
ENV MONGO_PACKAGE=${MONGO_PACKAGE} MONGO_REPO=${MONGO_REPO}

RUN echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-${MONGO_MAJOR}.gpg ] http://$MONGO_REPO/apt/ubuntu jammy/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"

# http://docs.mongodb.org/master/release-notes/4.2/
ENV MONGO_VERSION="7.0.14"

RUN set -x \
# installing "mongodb-enterprise" pulls in "tzdata" which prompts for input
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
# starting with MongoDB 4.3 (and backported to 4.0 and 4.2 *and* 3.6??), the postinst for server includes an unconditional "systemctl daemon-reload" (and we don't have anything for "systemctl" to talk to leading to dbus errors and failed package installs)
	&& ln -s /bin/true /usr/local/bin/systemctl \
	&& apt-get install -y \
		${MONGO_PACKAGE}=$MONGO_VERSION \
		${MONGO_PACKAGE}-server=$MONGO_VERSION \
		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
		mongodb-mongosh \
	&& rm -f /usr/local/bin/systemctl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb \
	&& mv /etc/mongod.conf /etc/mongod.conf.orig

RUN mkdir -p /opt/bitnami/mongodb/bin \
  && ln -s /usr/bin/install_compass            /opt/bitnami/mongodb/bin/ \
  && ln -s /usr/bin/bsondump                   /opt/bitnami/mongodb/bin/ \
  && ln -s /usr/bin/mongo*                     /opt/bitnami/mongodb/bin/ \
  && rm -rf /etc/mysql/mongodb.cnf \
  && chown 1001:1001 -R /opt/bitnami/mongodb


# mongodb-shell in mongodb

ADD https://raw.githubusercontent.com/mikefarah/yq/master/LICENSE /opt/bitnami/common/licenses/LICENSE
COPY --from=yq /usr/bin/yq /opt/bitnami/common/bin/

RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/mongodb/postunpack.sh
ENV APP_VERSION="7.0.14" \
    BITNAMI_APP_NAME="mongodb" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/mongodb/bin:$PATH"

EXPOSE 27017

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mongodb/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mongodb/run.sh" ]
