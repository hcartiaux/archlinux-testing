#!/usr/bin/env bats

load ../helpers/setup

export DEPENDS=(gcc)

@test "sqlite is installed" {
  crun [ -f /usr/bin/sqlite3 ]
  assert_success
}

@test "gcc can compile a program using libsqlite" {
  crun gcc -lsqlite3 test.c -o /tmp/test
  assert_success
}

@test "compiled program is linked to libsqlite" {
  is_linked_by_file /tmp/test
  assert_success
}

@test "compiled program can be executed" {
  crun /tmp/test
  assert_success
}

@test "sqlite db file created with sqlite 3.53 can be used" {
  crun sqlite3 -list fruits.db "SELECT fruit_color FROM fruits WHERE fruit_name = 'Banana'"
  assert_output "Yellow"
}

@test "sqlite db file created in previous steps is correct" {
  crun sqlite3 -list /tmp/fruits.db "SELECT * FROM fruits"
  cat << EOF | assert_output -
1|Banana|Yellow
3|Lemon|Yellow
4|Strawberry|Red
5|Watermelon|Green
6|Lime|Green
EOF
}
