#!/usr/bin/env bats

export DEPENDS=(python)

load ../helpers/setup

@test "Python is linked to mpdecimal" {
  is_linked_by_pkg python
  assert_success
}

@test "Python decimal module is useable" {
  crun python3 -c "from decimal import Decimal; print(Decimal('666') + Decimal('0.666'))"
  assert_output "666.666"
}
