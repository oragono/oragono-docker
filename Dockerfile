# build Oragono
FROM golang:rc AS build-env

RUN apt-get install -y git

RUN mkdir -p /go/src/github.com/oragono
WORKDIR /go/src/github.com/oragono

RUN git clone https://github.com/oragono/oragono.git
WORKDIR /go/src/github.com/oragono/oragono
RUN git submodule update --init

# compile
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s" -o build/docker/oragono oragono.go

# run in a lightweight distro
FROM alpine

# install latest updates and configure alpine
RUN apk update
RUN apk upgrade
RUN mkdir /lib/modules

# standard ports listened on
EXPOSE 6667/tcp 6697/tcp

# prep and copy oragono from build environment
RUN mkdir -p /ircd
WORKDIR /ircd
COPY --from=build-env /go/src/github.com/oragono/oragono/build/docker/ .
COPY --from=build-env /go/src/github.com/oragono/oragono/oragono.yaml ./ircd.yaml

# init
RUN ./oragono initdb
RUN ./oragono mkcerts

# launch
CMD ./oragono run

# uncomment to debug
#RUN apk add bash nano
#CMD /bin/bash
