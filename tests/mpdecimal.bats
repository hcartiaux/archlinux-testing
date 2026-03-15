#!/usr/bin/env bats

export PACKAGES=(mpdecimal python)

load '../helpers/setup'

@test "Python is linked to mpdecimal" {
  crun bash <<'EOF'
    python_declib="$(pacman -Ql python | grep -o '/.*/_decimal\.cpython-.*.so')"
    ldd "$python_declib" | grep libmpdec.so
EOF
  assert_success
}

@test "Python decimal module is useable" {
  crun python3 -c "from decimal import Decimal; print(Decimal('666') + Decimal('0.666'))"
  assert_output "666.666"
}
