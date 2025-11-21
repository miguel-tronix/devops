#!/bin/bash
microk8s.kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 2> /dev/null
