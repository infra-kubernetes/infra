#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly NAME=${2:-$(basename "${PWD%/*}")}
export readonly VERSION=${3:-$(basename "$PWD")}
rm -rf charts
rm -rf gpu-operator
rm -rf manifests
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
# Get the chart version from the app version
chart_version=`helm search repo --versions --regexp '\vnvidia/gpu-operator\v' |grep ${VERSION#v} | awk '{print $2}' | sort -rn | head -n1`
helm pull nvidia/gpu-operator --version=${chart_version} -d charts/ --untar