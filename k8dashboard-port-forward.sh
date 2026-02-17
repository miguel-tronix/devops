#!/bin/bash

echo "Starting persistent port-forward for Kubernetes Dashboard on port 14333..."
while true; do
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 14333:443
  echo "Port-forward exited with code $?. Restarting in 5 seconds..."
  sleep 5
done

