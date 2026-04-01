#!/usr/bin/env bats

DEPENDS=(tar)

load ../helpers/setup

@test "xz is installed" {
  crun [ -f /usr/bin/xz ]
  assert_success
}

@test "xz reports a version" {
  crun xz --version
  assert_output --regexp '^xz.*[0-9\.]+$'
}

@test "tar can create an archive with xz" {
  crun bash -c "
    mkdir -p /tmp/xztest/src
    echo 'hello' > /tmp/xztest/src/file.txt
    tar -cJf /tmp/xztest/archive.tar.xz -C /tmp/xztest/src .
  "
  crun [ -f /tmp/xztest/archive.tar.xz ]
  assert_success
}

@test "tar can extract an archive with xz" {
  crun bash -c "
    mkdir -p /tmp/xztest/dst
    tar -xJf /tmp/xztest/archive.tar.xz -C /tmp/xztest/dst
  "
  crun [ -f /tmp/xztest/dst/file.txt ]
  assert_success
}

@test "extracted file content matches original" {
  crun cat /tmp/xztest/dst/file.txt
  assert_output "hello"
}
