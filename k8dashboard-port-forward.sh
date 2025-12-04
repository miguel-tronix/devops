#!/bin/bash
if [ -z $1 ];then 
	kubectl -n kubernetes-dashboard rollout restart deployment kubernetes-dashboard-kong
	sleep 10
fi
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 2> /dev/null

