#!/usr/bin/env bash
script_path="$BASH_SOURCE[0]"
subdir_path=$(dirname "$script_path")
cd $subdir_path
./love-11.5-x86_64.AppImage .
