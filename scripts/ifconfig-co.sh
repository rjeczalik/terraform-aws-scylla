#!/bin/bash

set -eu

curl -sSL ifconfig.co | xargs -I{} echo $'{"public_ip":"{}"}'
