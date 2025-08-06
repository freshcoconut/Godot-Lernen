#!/bin/sh
echo -ne '\033c\033]0;Legende_des_Helden\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Legende_des_Helden_20250806_v_11.x86_64" "$@"
