#!/bin/bash

SENTINEL_ENDPOINT="127.0.0.1"
SENTINEL_PORT="26379"
MASTER_GROUP_NAME="redis"

kubectl_get () {
  EXTERNAL_IP=`kubectl get svc $EXTERNAL_NAME | awk 'NR > 1 {print  $4}'`
}

sentinel_masterip_get () {
  MASTER_IP=`redis-cli -h $SENTINEL_ENDPOINT -p $SENTINEL_PORT sentinel get-master-addr-by-name $MASTER_GROUP_NAME | awk 'NR==1 {print $1}'`
}

kubectl_patch () {
  kubectl patch svc $EXTERNAL_NAME --type="strategic"  -p '{"spec": {"externalName": "'$MASTER_IP'" }}'
}

set -xe

if ! kubectl version > /dev/null 2>&1; then
  echo "kubectl is not installed!"
fi

if [ "${EXTERNAL_NAME}" == "" ]; then
  echo "EXTERNAL_NAME is not specified!"
  exit 0
fi


DATETIME=`date +%Y%m%d_%H%M%S_%3N`
kubectl_get
echo "[$DATETIME] $EXTERNAL_NAME: $EXTERNAL_IP"

DATETIME=`date +%Y%m%d_%H%M%S_%3N`
sentinel_masterip_get
echo "[$DATETIME] REDIS_MASTER is $MASTER_IP"

DATETIME=`date +%Y%m%d_%H%M%S_%3N`
kubectl_patch
echo "[$DATETIME] Patched $EXTERNAL_NAME $EXTERNAL_IP"

DATETIME=`date +%Y%m%d_%H%M%S_%3N`
kubectl_get
echo "[$DATETIME] $EXTERNAL_NAME: $EXTERNAL_IP"
