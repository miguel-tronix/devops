#!/bin/bash

podman image rm -f $( podman image ls | grep localhost | awk '{ print $3 }')
