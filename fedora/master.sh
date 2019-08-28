#!/bin/sh

# Stop in case of error
set -e

enable_color() {
  ENABLECOLOR='-c '
  ANSI_RED="\033[31m"
  ANSI_GREEN="\033[32m"
  ANSI_YELLOW="\033[33m"
  ANSI_BLUE="\033[34m"
  ANSI_MAGENTA="\033[35m"
  ANSI_CYAN="\033[36;1m"
  ANSI_DARKCYAN="\033[36m"
  ANSI_NOCOLOR="\033[0m"
}

disable_color() { unset ENABLECOLOR ANSI_RED ANSI_GREEN ANSI_YELLOW ANSI_BLUE ANSI_MAGENTA ANSI_CYAN ANSI_DARKCYAN ANSI_NOCOLOR; }
enable_color

print_start() {
  if [ "x$2" != "x" ]; then
    COL="$2"
  elif [ "x$BASE_COL" != "x" ]; then
    COL="$BASE_COL"
  else
    COL="$ANSI_YELLOW"
  fi
  printf "${COL}${1}$ANSI_NOCOLOR\n"
}

gstart () {
  print_start "$@"
}
gend () {
  :
}

[ -n "$CI" ] && {
  echo "INFO: set 'gstart' and 'gend' for CI"
  gstart () {
    printf '::group::'
    print_start "$@"
    SECONDS=0
  }

  gend () {
    duration=$SECONDS
    echo '::endgroup::'
    printf "${ANSI_GRAY}took $(($duration / 60)) min $(($duration % 60)) sec.${ANSI_NOCOLOR}\n"
  }
} || echo "INFO: not in CI"

#---

case "$1" in
  -c)
    gstart 'Prepare /tmp/build'
      mkdir /tmp/build
      cp -vr /wrk/master/* /tmp/build/
      cd /tmp/build
    gend

    gstart 'Set dummy git repo and fedora remote'
      git init
      git config --local user.name 'fedora'
      git config --local user.email 'fedora@ghdl'
      git add ghdl.spec
      git commit -m wip
      git remote add origin https://src.fedoraproject.org/rpms/ghdl.git
      git fetch origin
      git branch -u origin/master
    gend

    dnf builddep -y ghdl.spec
    fedpkg sources
    fedpkg local

    gstart 'Copy artifacts'
      mkdir -p /wrk/srpm-master
      mv *.src.rpm /wrk/srpm-master/
      mv x86_64 /wrk/x86_64-master
    gend
  ;;
  -t)
    cd x86_64-master
    dnf install -y \
      ghdl-*-debugsource-*.rpm \
      ghdl-*-debuginfo-*.rpm \
      ghdl*-0*.rpm \
      ghdl*-grt*.rpm
    cd ..
    GHDL=ghdl ./testsuite/testsuite.sh
  ;;
  *)
    cd $(dirname $0)/master

    echo "Update GHDL tarball"

    gstart 'Git clone https://github.com/ghdl/ghdl'
      git clone --depth=1 https://github.com/ghdl/ghdl
      cd ghdl
      GHDL_GITVER="$(git log -1 --date=short --pretty=format:%cd | sed 's/-//g')git$(git rev-parse --short=8 --verify HEAD)"
      cd ..
    gend

    gstart 'Create ghdl.${GHDL_GITVER}.tar.bz2'
      tar cvJf ghdl.${GHDL_GITVER}.tar.bz2 --exclude-vcs ghdl
    gend

    gstart 'Copy testsuite'
      cp -vr ghdl/testsuite ../
    gend

    rm -rf ghdl

    gstart "Update 'ghdl.spec' and 'sources'"
      sed -i.bak "s/.*ghdl.*/$(sha512sum ghdl.${GHDL_GITVER}.tar.bz2 | sed 's/\(.*\) .*\(ghdl.*\)/SHA512 (\2) = \1/g')/g" sources
      sed -i.bak 's/\(%global ghdlgitrev\).*/\1 '"${GHDL_GITVER}"'/g' ghdl.spec
      rm *.bak
    gend

    cd ..

    docker run --rm -v /$(pwd):/wrk -w //wrk/master ghdl/dist:rpm //wrk/master.sh -c

    docker run --rm -v /$(pwd):/wrk -w //wrk ghdl/dist:rpm //wrk/master.sh -t
  ;;
esac
