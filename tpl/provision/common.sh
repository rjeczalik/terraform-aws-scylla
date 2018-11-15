#!/bin/bash -x

set -eu

curl -o /usr/bin/yq -sSL https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64
chmod +x /usr/bin/yq
