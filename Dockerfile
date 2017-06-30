# build Oragono
FROM golang:rc AS build-env

RUN apt-get install -y git

RUN mkdir -p /go/src/github.com/oragono
WORKDIR /go/src/github.com/oragono

RUN git clone https://github.com/oragono/oragono.git
WORKDIR /go/src/github.com/oragono/oragono
RUN git submodule update --init
RUN make linux

# run in Alpine, being a lightweight distro
FROM alpine:latest
EXPOSE 6667/tcp 6697/tcp

RUN mkdir -p /ircd
WORKDIR /ircd

COPY --from=build-env /go/src/github.com/oragono/oragono/build/oragono-XXX-linux.tgz /
RUN tar -xzf /oragono-XXX-linux.tgz
COPY run.sh /ircd

CMD ["./run.sh"]
