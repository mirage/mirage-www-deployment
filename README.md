mirage-www-deployment
=====================

Contains binaries of the various mirage-www websites that have been deployed
live.  This repo is used by the servers to actually the run the result of a
Travis CI build run.

<http://openmirage.org>

## Deploy

`./scripts/post-merge.hook` will be run on every commit. This scripts needs:

- The SSL keys located into:
```
./tls/tls/server.key
./tls/tls/server.pem
```

- The `fat` binary installed with `ocaml-fat` installed in:
```
./bin/fat
```