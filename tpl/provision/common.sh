#!/bin/bash -x

set -eu

curl -o /usr/bin/yq -sSL https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64
chmod +x /usr/bin/yq

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

cat <<EOF | while read key; do echo "$key" >> ~/.ssh/authorized_keys; done
${public_keys}
EOF
