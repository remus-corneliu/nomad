FROM alpine:3.12

## Create a nomad user and group first so the IDs get set the same way, even as the rest of this may change over time.
RUN addgroup nomad && \
    adduser -S -G nomad nomad

## Set up certificates and base tools.
## libc6-compat is needed to symlink the shared libraries for ARM builds
## https://www.computerhope.com/unix/uset.htm
RUN set -eux && \
    apk update && \
    apk add --no-cache tzdata && \
    apk add --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec iputils jq libc6-compat && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C

# nomad variables
# ENV NOMAD_VERSION=0.8.7
ENV NOMAD_VERSION=1.0.3
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

# install Nomad
# https://stackoverflow.com/questions/46221063/what-is-build-deps-for-apk-add-virtual-command
# https://stackoverflow.com/questions/43681432/explanation-of-the-update-add-command-for-alpine-linux
RUN apk --update add --no-cache --virtual .nomad-deps dpkg gnupg && \
    mkdir /tmp/build/ && \
    cd /tmp/build/ && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
    grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip && \
    chmod +x /bin/nomad && \
    cd /tmp && \
    rm -rf /tmp/build && \
    gpgconf --kill all && \
    apk del gnupg openssl .nomad-deps && \
    rm -rf /root/.gnupg
# check if nomad was insatlled with success
    # nomad version

# The /nomad/data dir is used by NOMAD to store state. The agent will be started
# with /nomad/config as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /nomad/data && \
    mkdir -p /nomad/config && \
    chown -R nomad:nomad /nomad

# Expose the NOMAD data directory as a volume since there's mutable state in there.
VOLUME /nomad/data

EXPOSE 4646 4647 4648 4648/udp

COPY nomad.startup.sh /usr/local/bin/
COPY nomad.server.hcl /nomad/config

ENTRYPOINT ["nomad.startup.sh"]