#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly NAME=grafana-operator
export readonly VERSION=v5.16.0

rm -rf charts images/shim && mkdir -p manifests images/shim

#wget -qO- https://github.com/grafana-operator/grafana-operator/archive/refs/tags/${VERSION}.tar.gz | tar -xz
#
#GrafanaImage=$(cat grafana-operator-${VERSION#v}/controllers/config/operator_constants.go |grep GrafanaImage | awk -F "[\"\"]" '{print $2}')
#GrafanaVersion=$(cat grafana-operator-${VERSION#v}/controllers/config/operator_constants.go |grep GrafanaVersion | awk -F "[\"\"]" '{print $2}')
#echo $GrafanaImage:$GrafanaVersion > images/shim/grafana-operator-images.txt
#
#rm -rf grafana-operator-${VERSION#v}

helm template grafana-operator hcharts/grafana-operator  --values hcharts/grafana-operator/values.yaml   --debug > manifests/grafana-operator.yaml

echo "ghcr.io/infra-kubernetes/base:grafana_plugins_v1" > images/shim/v1.txt
echo "ghcr.io/infra-kubernetes/base:grafana_plugins_v2" > images/shim/v2.txt
echo "docker.m.daocloud.io/grafana/grafana:11.3.0" > images/shim/grafana.txt