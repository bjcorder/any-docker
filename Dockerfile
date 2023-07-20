# Version: 0.0.1
#
# CHANGELOG
## [Unreleased]
## [0.0.1] - 2023-07-20
### Added
## * golang:1.19-bullseye as base image (golang:1.19 is currently supported by Anytype)
## * Additional dependencies to git clone Anytype repos
## * Clone and install any-sync-tool
## * Clone and build any-sync-coordinator

# TODO
# * Use any-sync-tool with Dockerfile ARG's from ENV file to create any-sync-network yaml configuration files
# * Build any-sync-node
# * Build any-sync-filenode

ENV any-sync-coordinator-node-address=127.0.0.1:4830
ENV mongo-connect-uri=mongodb://localhost:27017
ENV mongo-database-name=coordinator
ENV any-sync-node-address=127.0.0.1:4430
ENV any-sync-file-node-address=127.0.0.1:4730
ENV s3-endpoint
ENV s3-region=eu-central-1
ENV s3-profile=default
ENV s3-bucket=any-sync-files
ENV redis-url=redis://127.0.0.1:6379/?dial_timeout=3&db=1&read_timeout=6s&max_retries=2
ENV is-cluster=false

FROM golang:1.19-bullseye

MAINTAINER Sam Bouwer

# Install dependencies

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                git \
                openssl \
        ; \
        rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOPATH /go

ENV PATH $GOPATH/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

WORKDIR /anytype

# Create config with any-sync-tool

RUN git clone https://github.com/anyproto/any-sync-tools
WORKDIR /anytype/any-sync-tools
RUN go install ./any-sync-network
RUN any-sync-network create

# Build any-sync-coordinator

WORKDIR /anytype

RUN git clone https://github.com/anyproto/any-sync-coordinator

WORKDIR /anytype/any-sync-coordinator

RUN make deps
RUN make build
