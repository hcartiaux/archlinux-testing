#!/usr/bin/env bash

fail() {
  echo " ✗ $*" >&3
  return 1
}

success() {
  echo " ✓ $*" >&3
  return 0
}

newline() {
  echo >&3
}
