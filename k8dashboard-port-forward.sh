#!/bin/bash
if [ -z $1 ];then 
	kubectl -n kubernetes-dashboard rollout restart deployment kubernetes-dashboard-kong
fi

echo "Starting persistent port-forward for Kubernetes Dashboard..."
while true; do
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 2> /dev/null
  echo "Port-forward exited with code $?. Restarting in 5 seconds..."
  sleep 5
done
