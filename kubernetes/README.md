# vocdoni-k8s

Helper files and k8s manifest for dealing with the k8s vocdoni infrastructure.

The directory contains the following files:
- manage.sh a helper script (with help and flags)
- the k8s yaml manifest files for deploying the service
- a `kube` subdirectory with the k8s config file and api-keys for connecting the k8s cluster

Generate a private key: `hexdump -n 32 -e '4/4 "%08x" 1 ""' /dev/urandom`

Copy your kubernetes api config file into the kube directory.

Launch the node:

```bash
export KUBECONFIG=kube/api.kube
kubectl apply -f service.yaml
./manage.sh secret <PRIVATE_KEY>
# <wait until load balancer is creted and have external IP: kubectl get service>
./manage.sh apply
```

Now monitor with:
```bash
kubectl get pods
./manage.sh get-events
./manage.sh logs
```

For triggering a restart of the service preserving data store (i.e to force update the docker image): `./mange.sh restart`

For making a full reset of the service and its data (permanent loss): `./manage.sh full-reset`

You can get the external IP of the service with: `./manage.sh ip`

---

At this point **if you want your node to become validator**, you need to extract the 
public key from the logs: 

`docker compose logs  vocdoninode | grep publicKey`.

Provide the public key and a fancy name to the Vocdoni team so they can upgrade your node to validator.

