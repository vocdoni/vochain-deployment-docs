#!/bin/bash
DEFAULTPOD="vocdoni-node-0-0"

setip() {
    EXTERNAL_IP=$(kubectl get svc vocdoni-node-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -z "$EXTERNAL_IP" ]; then echo "could not find external IP"; exit 1; fi
    echo "External IP is $EXTERNAL_IP"
    kubectl delete secret vocdoni-node-ip 2>/dev/null
    kubectl create secret generic vocdoni-node-ip --from-literal=public-ip="$EXTERNAL_IP:26656"
} 

# Function to display the usage of the script.
usage() {
  echo "Usage: $0 [COMMAND] [OPTION]"
  echo
  echo "Commands:"
  echo "  apply           Apply all YAML configurations in the current directory."
  echo "  restart         Restart the existing pods and force a container image re-pull."
  echo "  full-reset      Remove everything (including volumes) and re-create."
  echo "  download-data   Download the current volume data (Requires a pod name and optionally a volume path)."
  echo "  get-events      Get the latest events from the Kubernetes cluster."
  echo "  logs            Get logs of a specific pod (Requires a pod name)."
  echo "  top             Show the top resource-consuming processes."
  echo "  secret <hex>    Create the signing key secret."
  echo "  ip              Get ip information."
  echo "  setip           Force the vocdoni config to use the loadbalancer external IP."
  echo
  echo "Options:"
  echo "  --pod           Specify the pod name (used for logs, download-data)."
  echo "  --path          Specify the volume path in the pod (used for download-data)."
  echo
  echo "Example:"
  echo "  $0 apply"
  echo "  $0 logs --pod mypod"
  exit 1
}

# Check if at least one command was provided.
if [ "$#" -eq 0 ]; then
    usage
fi

ACTION=$1
shift  # shift the $1 argument, the rest are treated as additional parameters.

case $ACTION in
  apply)
    kubectl apply -f ./
    ;;
    
  restart)
    kubectl delete pods --all --wait=true
    setip
    # This assumes that you have a deployment or replica set that will recreate the pods.
    ;;

  full-reset)
    kubectl delete statefulset vocdoni-node-0
    kubectl delete pvc --all
    kubectl apply -f ./
    setip
    ;;

  download-data)
    POD=""
    VOLUME_PATH="."  # current directory by default
    while [[ "$#" -gt 0 ]]; do
      case $1 in
        --pod) POD="$2"; shift ;;
        --path) VOLUME_PATH="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
      esac
      shift
    done
    if [[ -z "$POD" ]]; then POD=$DEFAULTPOD ;fi
    kubectl cp "${POD}:${VOLUME_PATH}" ./data
    ;;

  get-events)
    kubectl get events --sort-by='.metadata.creationTimestamp'
    ;;

  logs)
    POD=""
    while [[ "$#" -gt 0 ]]; do
      case $1 in
        --pod) POD="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
      esac
      shift
    done
    if [[ -z "$POD" ]]; then POD=$DEFAULTPOD; fi
    kubectl logs "$POD"
    ;;

  top)
    kubectl top nodes
    kubectl top pods
    ;;

  secret)
    echo "secret $1"
    kubectl delete secret vocdoni-signing-key
    kubectl create secret generic vocdoni-signing-key --from-literal=signing-key="$1"
    ;;

  ip)
    kubectl get service vocdoni-node-service
    ;;

  setip)
    setip
    ;;
 
  *)
    echo "Invalid command: $ACTION"
    usage
    ;;
esac

