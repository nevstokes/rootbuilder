FROM debian:buster-slim

ARG BUILDROOT_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

WORKDIR /tmp/buildroot

RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" \
    | debconf-set-selections \
  && echo "locales locales/default_environment_locale select en_US.UTF-8" \
    | debconf-set-selections \
  && apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -q -y \
    axel \
    bc \
    build-essential \
    cpio \
    git-core \
    gnupg \
    libc6-i386 \
    libncurses-dev \
    locales \
    python \
    rsync \
    unzip \
    wget \
  \
  && axel -q https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz \
  && wget -q https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz.sign \
  && wget -qO- https://uclibc.org/~jacmet/pubkey.gpg | gpg --import \
  && tar xzf buildroot-${BUILDROOT_VERSION}.tar.gz --strip-components=1 \
  && rm buildroot-${BUILDROOT_VERSION}.tar.gz.sign buildroot-${BUILDROOT_VERSION}.tar.gz

LABEL org.opencontainers.image.vendor="nevstokes" \
    org.opencontainers.image.description="Buildroot image for creating rootfs archives" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.version="v${BUILDROOT_VERSION}"
