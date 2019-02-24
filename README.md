# Oragono Docker

This repo holds [Oragono](https://github.com/oragono/oragono)'s Dockerfiles and
related materials.

## Tags

The following tags are available:

 * `latest` - latest stable release
 * `dev` - latest development version (may be unstable)

## Quick start

The Oragono docker image is designed to work out of the box - it comes with a
usable default config and will automatically generate self-signed TLS
certificates. To get a working ircd, all you need to do is run the image and
expose the ports:

```shell
docker run --name oragono -d -P oragono/oragono:tag
```

This will start Oragono and listen on ports 6667 (plain text) and 6697 (TLS).
The first time Oragono runs it will create a config file with a randomised
oper password. This is output to stdout, and you can view it with the docker
logs command:

```shell
# Assuming your container is named `oragono`; use `docker container ls` to
# find the name if you're not sure.
docker logs oragono
```

You should see a line similar to:

```
Oper username:password is dan:cnn2tm9TP3GeI4vLaEMS
```

## Persisting data

Oragono has a persistent data store, used to keep account details, channel
registrations, and so on. To persist this data across restarts, you can mount
a volume at /ircd.

For example, to create a new docker volume and then mount it:

```shell
docker volume create oragono-data
docker run -d -v oragono-data:/ircd -P oragono/oragono:tag
```

Or to mount a folder from your host machine:

```shell
mkdir oragono-data
docker run -d -v $(PWD)/oragono-data:/ircd -P oragono/oragono:tag
```

## Customising the config

Oragono's config file is stored at /ircd/ircd.yaml. If the file does not
exist, the default config will be written out. You can copy the config from
the container, edit it, and then copy it back:

```shell
# Assuming that your container is named `oragono`, as above.
docker cp oragono:/ircd/ircd.yaml .
vim ircd.yaml # edit the config to your liking
docker cp ircd.yaml oragono:/ircd/ircd.yaml
```

You can use the `/rehash` command to make Oragono reload its config, or
send it the HUP signal:

```shell
docker kill -HUP oragono
```

## Using custom TLS certificates

TLS certs will by default be read from /ircd/tls.crt, with a private key
in /ircd/tls.key. You can customise this path in the ircd.yaml file if
you wish to mount the certificates from another volume. For information
on using Let's Encrypt certificates, see
[this manual entry](https://github.com/oragono/oragono/blob/master/docs/MANUAL.md#how-do-i-use-lets-encrypt-certificates).

## Using docker-compose

This repository contains a sample docker-compose file which can be used
to start an Oragono instance with ports exposed and data persisted in
a docker volume. Simply download the file and then bring it up:

```shell
curl -O https://raw.githubusercontent.com/oragono/oragono-docker/master/docker-compose.yml
docker-compose up -d
```
