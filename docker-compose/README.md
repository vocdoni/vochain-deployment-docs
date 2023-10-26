# docker compose deployment

Generate a private key: `hexdump -n 32 -e '4/4 "%08x" 1 ""' /dev/urandom`

Clone and prepare environment:
```bash
git clone https://github.com/vocdoni/vocdoni-node.git -b release-lts-1
cd vocdoni-node/dockerfiles/vocdoninode
echo "VOCDONI_NODE_TAG=release-lts-1" > .env
```

Create the config `env` file.

```bash
VOCDONI_DATADIR=/app/run
VOCDONI_MODE=miner
VOCDONI_CHAIN=lts
VOCDONI_LOGLEVEL=info
VOCDONI_DEV=True
VOCDONI_ENABLEAPI=False
VOCDONI_ENABLERPC=False
VOCDONI_LISTENHOST=0.0.0.0
VOCDONI_LISTENPORT=9090
VOCDONI_VOCHAIN_MINERKEY=<YOUR_HEX_PRIVATE_KEY>
VOCDONI_VOCHAIN_MEMPOOLSIZE=20000
VOCDONI_METRICS_ENABLED=True # if you want prometheus metrics enabled
VOCDONI_METRICS_REFRESHINTERVAL=5
```

Finally start the container: `RESTART=always docker compose up -d`

You can monitor the log output: `docker compose logs -f vocdoninode`

---

At this point **if you want your node to become validator**, you need to extract the 
public key from the logs: 

`docker compose logs  vocdoninode | grep publicKey`.

Provide the public key and a fancy name to the Vocdoni team so they can upgrade your node to validator.

