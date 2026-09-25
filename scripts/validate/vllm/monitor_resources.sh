#!/usr/bin/env bash

set -u

while true
do
    printf '%s ' "$(date -Is)"

    free -b \
      | awk '/^Mem:/ {
          printf "ram_used=%s ram_available=%s ",
          $3, $7
        }'

    nvidia-smi \
      --query-gpu=memory.used,memory.free \
      --format=csv,noheader,nounits \
      | awk -F',' '{
          gsub(/ /,"",$1)
          gsub(/ /,"",$2)
          printf "vram_used_mib=%s vram_free_mib=%s\n",
          $1,$2
        }'

    sleep 1
done
