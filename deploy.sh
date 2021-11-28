#!/bin/bash

cd iac

BUILD_VERSION=`sed 's/BUILD_VERSION=//g' .env`
PROVISIONED=`dig +short cluster-manager.$CLOUDFLARE_ZONE_NAME`
KUBECTL_CMD=`which kubectl`

if [ ! -f "./.id_rsa" ]; then
  echo "$LINODE_PRIVATE_KEY" > ./.id_rsa

  chmod og-rwx ./.id_rsa
fi

if [ -z "$KUBECTL_CMD" ]; then
  KUBECTL_CMD=./kubectl
fi

if [ -z "$PROVISIONED" ]; then
  TERRAFORM_CMD=`which terraform`

  if [ -z "$TERRAFORM_CMD" ]; then
    TERRAFORM_CMD=./terraform
  fi

  $TERRAFORM_CMD init
  $TERRAFORM_CMD apply -auto-approve \
                       -var "token=$LINODE_TOKEN" \
                       -var "public_key=$LINODE_PUBLIC_KEY" \
                       -var "private_key=$LINODE_PRIVATE_KEY" \
                       -var "email=$CLOUDFLARE_EMAIL" \
                       -var "api_key=$CLOUDFLARE_API_KEY" \
                       -var "zone_id=$CLOUDFLARE_ZONE_ID" \
                       -var "zone_name=$CLOUDFLARE_ZONE_NAME"

  CLUSTER_MANAGER_IP=`cat cluster-manager-ip`

  rm cluster-manager-ip

  if [ ! -f "./.kubeconfig" ]; then
    scp -i ./.id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$CLUSTER_MANAGER_IP:/etc/rancher/k3s/k3s.yaml ./.kubeconfig

    sed -i -e 's|127.0.0.1|'"$CLUSTER_MANAGER_IP"'|g' ./.kubeconfig

    rm -f ./.kubeconfig-e
  fi

  cp ./kubernetes.yml /tmp/kubernetes.yml

  sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' /tmp/kubernetes.yml

  $KUBECTL_CMD --kubeconfig=./.kubeconfig apply -f /tmp/kubernetes.yml

  rm /tmp/kubernetes.yml
else
  if [ ! -f "./.kubeconfig" ]; then
    scp -i ./.id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@cluster-manager.${CLOUDFLARE_ZONE_NAME}:/etc/rancher/k3s/k3s.yaml ./.kubeconfig

    sed -i -e 's|127.0.0.1|'"cluster-manager.$CLOUDFLARE_ZONE_NAME"'|g' ./.kubeconfig

    rm -f ./.kubeconfig-e
  fi

  $KUBECTL_CMD --kubeconfig=./.kubeconfig set image deployment database database=ghcr.io/fvilarinho/demo-database:$BUILD_VERSION
  $KUBECTL_CMD --kubeconfig=./.kubeconfig set image daemonset backend backend=ghcr.io/fvilarinho/demo-backend:$BUILD_VERSION
  $KUBECTL_CMD --kubeconfig=./.kubeconfig set image daemonSet frontend frontend=ghcr.io/fvilarinho/demo-frontend:$BUILD_VERSION
fi

cd ..