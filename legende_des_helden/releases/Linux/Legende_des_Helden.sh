#!/bin/sh
echo -ne '\033c\033]0;Legende_des_Helden\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Legende_des_Helden.x86_64" "$@"
