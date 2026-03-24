#!/usr/bin/env bats

load ../helpers/setup

export DEPENDS=(gcc)

@test "libmpc is installed" {
  crun [ -f /usr/lib/libmpc.so ]
  assert_success
}

@test "gcc can compile a program using libmpc" {
  crun gcc -lmpc asin2i.c -o /tmp/asin2i
  assert_success
}

@test "compiled program is linked to libmpc" {
  is_linked_by_file /tmp/asin2i
  assert_success
}

@test "compiled program can be executed" {
  crun /tmp/asin2i
  assert_output $'(0 1.44363547517881034249327674027310526938e0)\n0 -1'
}
