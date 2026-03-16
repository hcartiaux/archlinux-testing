#!/usr/bin/env bats

load ../helpers/setup

@test "Volume created" {
  crun dd if=/dev/zero of=/tmp/filesystem bs=1M count=10
  assert_success
}

@test "ext4 filesystem is created" {
  crun mkfs.ext4 /tmp/filesystem
  assert_success
}
@test "ext4 filesystem can be fsck'ed" {
  crun e2fsck -f -y /tmp/filesystem
  assert_success
}
@test "ext4 filesystem superblock can be listed" {
  crun tune2fs -l /tmp/filesystem
  assert_success
}

@test "ext3 filesystem is created" {
  crun mkfs.ext3 /tmp/filesystem
  assert_success
}
@test "ext3 filesystem can be fsck'ed" {
  crun e2fsck -f -y /tmp/filesystem
  assert_success
}
@test "ext3 filesystem superblock can be listed" {
  crun tune2fs -l /tmp/filesystem
  assert_success
}

@test "ext2 filesystem is created" {
  crun mkfs.ext2 /tmp/filesystem
  assert_success
}
@test "ext2 filesystem can be fsck'ed" {
  crun e2fsck -f -y /tmp/filesystem
  assert_success
}
@test "ext2 filesystem superblock can be listed" {
  crun tune2fs -l /tmp/filesystem
  assert_success
}
