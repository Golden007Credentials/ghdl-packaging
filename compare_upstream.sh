#!/bin/sh

ANSI_MAGENTA="\033[35m"
ANSI_NOCOLOR="\033[0m"

for x in mcode-git llvm-git gcc-git; do
    f="archlinux/${x}.upstream"
    curl -fsSL https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=ghdl-${x} -o "$f"
    printf "\n${ANSI_MAGENTA}\nDIFF $x${ANSI_NOCOLOR}\n\n"
    colordiff -y --strip-trailing-cr "$f" "archlinux/${x}/PKGBUILD" | colordiff
done
