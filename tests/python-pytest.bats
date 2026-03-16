#!/usr/bin/env bats

export PACKAGES=(python-pytest)

load ../helpers/setup

@test "python-pytest is installed" {
  crun [ -f /usr/bin/pytest ]
  assert_success
}

@test "pytest can execute a sample" {
  crun pytest
  assert_output --partial "FAILED test_sample.py::test_answer - assert 4 == 5"
}
