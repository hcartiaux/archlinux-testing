#!/usr/bin/env bash

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
}

load '../helpers/utils'
load '../helpers/container'
