#!/usr/bin/env bats

export DEPENDS=(parallel)

load ../helpers/setup

@test "perl is installed" {
  crun [ -f /usr/bin/perl ]
  assert_success
}

@test "perl can run a perl script" {
  crun ./fibonacci.pl
  assert_output "0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 "
}

@test "parallel is functional" {
  crun bash -c "parallel --plus echo Job {#} of {##} ::: {1..5}"
  assert_output --partial "Job 5 of 5"
}
