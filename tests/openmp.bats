#!/usr/bin/env bats

export DEPENDS=(clang)

load ../helpers/setup

@test "openmp is installed" {
  crun [ -f /usr/lib/libomp.so ]
  assert_success
}

@test "clang can compile an openmp program" {
  crun clang -fopenmp hello_world.c -o /tmp/hello_world
  assert_success
}

@test "compiled program is linked to openmp" {
  is_linked_by_file /tmp/hello_world
  assert_success
}

@test "compiled program can be executed with 4 threads" {
  crun bash -c "OMP_NUM_THREADS=4 /tmp/hello_world"
  assert_output --partial "Hello World... from thread = 3"
}
