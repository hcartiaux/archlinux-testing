#!/usr/bin/env bats

export PACKAGES=(tar)

load ../helpers/setup

@test "tar is installed" {
  crun [ -f /usr/bin/tar ]
  assert_success
}

@test "tar reports a version" {
  crun tar --version
  assert_output --regexp '^tar.*[0-9\.]+$'
}

@test "tar can create an archive" {
  crun bash -c "
    mkdir -p /tmp/tartest/src
    echo 'hello' > /tmp/tartest/src/file.txt
    tar -czf /tmp/tartest/archive.tar.gz -C /tmp/tartest/src .
  "
  crun [ -f /tmp/tartest/archive.tar.gz ]
  assert_success
}

@test "tar can extract an archive" {
  crun bash -c "
    mkdir -p /tmp/tartest/dst
    tar -xzf /tmp/tartest/archive.tar.gz -C /tmp/tartest/dst
  "
  crun [ -f /tmp/tartest/dst/file.txt ]
  assert_success
}

@test "extracted file content matches original" {
  crun cat /tmp/tartest/dst/file.txt
  assert_output "hello"
}
