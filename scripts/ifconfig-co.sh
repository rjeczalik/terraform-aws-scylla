#!/bin/bash

set -eu

curl -sSL ifconfig.me | xargs -I{} echo $'{"public_ip":"{}"}'
