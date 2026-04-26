#!/usr/bin/env bats

load ../helpers/setup

@test "sed is installed" {
  crun [ -f /usr/bin/sed ]
  assert_success
}

@test "sed is functional" {
  crun bash -c "echo Is sed functional? | sed 's/Is sed \([^?]*\)?/Sed is \1/'"
  assert_output "Sed is functional"
}

@test "sed script can be executed" {
  crun ./test.sed mirrorlist
  cat << EOF | assert_output -
Server = https://fastly.mirror.pkgbuild.com/\$repo/os/\$arch
Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch
Server = https://ftpmirror.infania.net/mirror/archlinux/\$repo/os/\$arch
Server = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch
EOF
}
