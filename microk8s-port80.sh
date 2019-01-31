#!/bin/bash

# This script will search the cluster for certmanager issuer services and proxy them
# over port 80 to the service NodePort one by one until they finish
# The primary use is with a microk8s install in a VM, where it is known to work

EXTERNAL_IP_DEV=eth0
TCP4_LISTEN_PORT=80
SLEEP_BETWEEN_CHECKS=10

if [ ! -z $1 ];
then
    EXTERNAL_IP_DEV=$1
fi

EXTERNAL_IP=$(ip addr show $EXTERNAL_IP_DEV | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')

if [ -z $EXTERNAL_IP ]
then
    echo "Unable to find IP from device $EXTERNAL_IP_DEV, unable to proceed"
    exit 1
fi

echo "Checking for listening cert-manager issuer service NodePorts"

listening_ports=$(kubectl get svc -o json | jq '.items[] | select (.spec.selector."certmanager.k8s.io/acme-http-domain") | .spec.ports[].nodePort')

if [ -z "$listening_ports" ];
then
    echo "No listening listening cert-manager issuer service NodePorts found, exiting"
    exit 0
else
    echo "Found the following listening cert-manager issuer service NodePorts:"
    echo "$listening_ports"
    echo "Using socat to proxy port $TCP4_LISTEN_PORT to those ports"
fi

for i in $listening_ports;
do
    loop_count=0
    node_port_exists=$(kubectl get svc -o json | (jq --arg MYPORT $i -r '.items[] | select (.spec.selector."certmanager.k8s.io/acme-http-domain") | .spec.ports[] | select (.nodePort == ($MYPORT | tonumber))'))
    until [ -z "$node_port_exists" ];
    do
        if [ -z "$socat_pid" ];
        then
            socat TCP4-LISTEN:$TCP4_LISTEN_PORT,fork TCP4:$EXTERNAL_IP:$i &
            socat_pid=$!
            echo "Port $i is listening, launched socat with pid: $socat_pid for this port until it disappears"
        fi
        loop_count=$((loop_count+1))
        echo "Sleeping for $SLEEP_BETWEEN_CHECKS before rechecking for port $i - check number $loop_count"
        sleep $SLEEP_BETWEEN_CHECKS  # sleep between loops to not overload the cluster
        node_port_exists=$(kubectl get svc -o json | (jq --arg MYPORT $i -r '.items[] | select (.spec.selector."certmanager.k8s.io/acme-http-domain") | .spec.ports[] | select (.nodePort == ($MYPORT | tonumber))'))
        if [ -z "$node_port_exists" ];
        then
            echo "Looks like port $i is no longer listening, killing the socat pid $socat_pid"
            kill -9 $socat_pid
            sleep 10  # sleep a bit so the process can end properly and free port $TCP4_LISTEN_PORT
            unset socat_pid
        fi
    done
done
