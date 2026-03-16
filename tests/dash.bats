#!/usr/bin/env bats

export PACKAGES=(dash)

load ../helpers/setup

@test "dash is installed" {
  crun [ -f /usr/bin/dash ]
  assert_success
}

@test "dash can execute a trivial shell script" {
  crun dash fibonacci.sh
  assert_output "0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 "
}
