#!/usr/bin/env bats

DEPENDS=(python-numpy)

load ../helpers/setup

@test "python-opencv can convert an image to gray scale" {
  crun python opencv.py
  assert_output "Checksum: 95b532cc4381affdff0d956e12520a04129ed49d37e154228368fe5621f0b9a2"
}
