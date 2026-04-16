#!/usr/bin/env bats

load ../helpers/setup

@test "file is installed" {
  crun file /usr/bin/file
  assert_output --partial "/usr/bin/file: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked"
}

@test "file recognizes a text file" {
  crun file /etc/services
  assert_output "/etc/services: ASCII text"
}

@test "file recognizes a symlink" {
  crun file /bin
  assert_output "/bin: symbolic link to usr/bin"
}

@test "file recognizes a directory" {
  crun file /usr
  assert_output "/usr: directory"
}

@test "file recognizes a character special file" {
  crun file /dev/zero
  assert_output --partial "/dev/zero: character special"
}
