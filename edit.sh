#!/usr/bin/env bash
# remember to set autoread
NIX_PORTABLE_LOC="$PWD"
find ./*.nix | entr -r bash -c "NP_LOCATION=$NIX_PORTABLE_LOC NP_RUNTIME='bwrap' $PWD/nix-portable nix build .#my_config -o init.nvim_store && cp -f $NIX_PORTABLE_LOC/.nix-portable/store/\$(basename \$(readlink $PWD/init.nvim_store)) $PWD/init.nvim"
# if on nixos
#find ./*.nix | entr -r bash -c "nix build .#my_config -o init.nvim_store && cp -f init.nvim_store init.nvim"
