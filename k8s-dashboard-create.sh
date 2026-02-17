#!/bin/bash
# Create the service account
kubectl create serviceaccount admin-user -n kubernetes-dashboard

# Bind it to the cluster-admin role
kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

# Generate the login token
kubectl -n kubernetes-dashboard create token admin-user
