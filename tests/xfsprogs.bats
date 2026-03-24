#!/usr/bin/env bats

load ../helpers/setup

@test "Volume created" {
  crun dd if=/dev/zero of=/tmp/filesystem bs=1M count=300
  assert_success
}

@test "xfs filesystem is created" {
  crun mkfs.xfs /tmp/filesystem
  assert_success
}
@test "xfs filesystem can be fsck'ed" {
  crun fsck -f -y /tmp/filesystem
  assert_success
}
@test "xfs filesystem can be repaired" {
  crun xfs_repair /tmp/filesystem
  assert_success
}
