#/bin/sh

# start in right dir
cd /ircd

# make config file
if [ ! -f "/ircd/ircd.yaml" ]; then
    awk '{gsub(/path: languages/,"path: /ircd-bin/languages")}1' /ircd-bin/oragono.yaml > /tmp/ircd.yaml
    mv /tmp/ircd.yaml /ircd/ircd.yaml
fi

# make db and certs
if [ ! -f "/ircd/ircd.db" ]; then
    /ircd-bin/oragono initdb
fi

if [ ! -f "/ircd/tls.key" ]; then
    /ircd-bin/oragono mkcerts
fi

# run!
/ircd-bin/oragono run
