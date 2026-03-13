#!/usr/bin/env bats
# tests/tar.bats — functional tests for tar

export PACKAGES=(openmp clang)
load '../helpers/setup'
load '../helpers/container'

@test "openmp is installed" {
  crun [ -f /usr/lib/libomp.so ]
  assert_success
}

@test "clang can compile an openmp program" {
  crun clang -fopenmp hello_world.c -o /tmp/hello_world
  crun [ -f '/tmp/hello_world' ]
  assert_success
}

@test "compiled program can be executed" {
  crun bash -c "OMP_NUM_THREADS=4 /tmp/hello_world"
  assert_output --partial "Hello World... from thread = 3"
}
