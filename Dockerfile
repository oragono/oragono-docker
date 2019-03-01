## build Oragono
FROM golang:rc-alpine AS build-env

RUN apk add --no-cache git make curl

# get oragono
RUN mkdir -p /go/src/github.com/oragono
WORKDIR /go/src/github.com/oragono

RUN git clone --recurse-submodules -b stable https://github.com/oragono/oragono.git
WORKDIR /go/src/github.com/oragono/oragono

# compile
RUN make



## run Oragono
FROM alpine:3.9

# metadata
LABEL maintainer="daniel@danieloaks.net"
LABEL description="Oragono is a modern, experimental IRC server written in Go"

# install latest updates and configure alpine
RUN apk update
RUN apk upgrade
RUN mkdir /lib/modules

# standard ports listened on
EXPOSE 6667/tcp 6697/tcp

# oragono itself
RUN mkdir -p /ircd-bin
COPY --from=build-env /go/bin/oragono /ircd-bin
COPY --from=build-env /go/src/github.com/oragono/oragono/languages /ircd-bin/languages/
COPY --from=build-env /go/src/github.com/oragono/oragono/oragono.yaml /ircd-bin/oragono.yaml
COPY run.sh /ircd-bin/run.sh
RUN chmod +x /ircd-bin/run.sh

# running volume holding config file, db, certs
VOLUME /ircd
WORKDIR /ircd

# default motd
COPY --from=build-env /go/src/github.com/oragono/oragono/oragono.motd /ircd/oragono.motd

# launch
ENTRYPOINT ["/ircd-bin/run.sh"]

# # uncomment to debug
# RUN apk add --no-cache bash
# RUN apk add --no-cache vim
# CMD /bin/bash
