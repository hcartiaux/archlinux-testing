#!/usr/bin/env bats

load ../helpers/setup

@test "volume A and B is created" {
  crun dd if=/dev/zero of=/tmp/device_a bs=2M count=100
  crun dd if=/dev/zero of=/tmp/device_b bs=2M count=100
  assert_success
}

@test "btrfs filesystem is created" {
  crun mkfs.btrfs /tmp/device_a
  assert_success
}

@test "btrfs filesystem can be checked" {
  crun btrfs check /tmp/device_a
  assert_success
}

@test "btrfs filesystem (raid 1) is created" {
  crun mkfs.btrfs -f -m raid1 -d raid1 /tmp/device_a /tmp/device_b
  assert_success
}
