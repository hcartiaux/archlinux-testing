#!/usr/bin/env bats
# tests/tar.bats — functional tests for tar

export PACKAGES="tar"
load '../helpers/setup'
load '../helpers/container'

@test "tar is installed" {
  assert [ -f /usr/bin/tar ]
}

@test "tar reports a version" {
  crun tar --version
  assert_output --regexp '^tar.*[0-9\.]+$'
}

@test "tar can create an archive" {
  crun bash -c "
    mkdir -p /tmp/tartest/src
    echo 'hello' > /tmp/tartest/src/file.txt
    ls bla
    tar -czf /tmp/tartest/archive.tar.gz -C /tmp/tartest/src .
  "
  crun [ -f '/tmp/tartest/archive.tar.gz' ]
  assert_success
}

@test "tar can extract an archive" {
  crun bash -c "
    mkdir -p /tmp/tartest/dst
    tar -xzf /tmp/tartest/archive.tar.gz -C /tmp/tartest/dst
  "
  crun [ -f '/tmp/tartest/dst/file.txt' ]
  assert_success
}

@test "extracted file content matches original" {
  crun cat /tmp/tartest/dst/file.txt
  assert_output "hello"
}
