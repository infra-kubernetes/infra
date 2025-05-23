#!/usr/bin/env bash

set -e
kubectl apply -f crds/
kubectl create -f charts/kubeblocks/crds/kubeblocks_crds.yaml || kubectl replace -f charts/kubeblocks/crds/kubeblocks_crds.yaml
sleep 2
helm upgrade -i kubeblocks charts/kubeblocks --set snapshot-controller.enabled=false --insecure-skip-tls-verify -n kb-system --create-namespace
cp -rf opt/kbcli /usr/bin/
kbcli addon enable apecloud-mysql
kbcli addon enable redis
kbcli addon enable postgresql
kbcli addon enable mongodb

KB_BACKUP_OPTS=${KB_BACKUP_OPTS:-"--endpoint minio.minio.svc:9000 --access-key-id admin --secret-access-key admin123"}

mc mb --ignore-existing local/backuprepo

REPO_NAME="backuprepo-default"
if kbcli backuprepo list | awk -v repo="$REPO_NAME" 'NR>1 && $1 == repo {found=1; exit} END {exit !found}'; then
    echo "备份仓库 '$REPO_NAME' 已存在，跳过创建。"
else
    echo "正在创建备份仓库 '$REPO_NAME'..."
    kbcli backuprepo create "$REPO_NAME" \
        --provider minio \
        --bucket backuprepo \
        --access-method Tool \
        ${KB_BACKUP_OPTS} \
        --default

    # 检查命令是否成功
    if [ $? -ne 0 ]; then
        echo "错误：创建备份仓库失败！"
        exit 1
    fi
fi

kbcli backuprepo list