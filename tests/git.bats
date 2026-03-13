#!/usr/bin/env bats
# tests/git.bats — functional tests for git

export PACKAGES="git"
load '../helpers/setup'
load '../helpers/container'

@test "git is installed" {
  assert [ -f '/usr/bin/git' ]
}

@test "git reports a version" {
  crun git --version
  assert_output --regexp '^git version [0-9\.]+$'
}

@test "git init creates a repository" {
  crun bash -c "mkdir -p /tmp/repo && git init /tmp/repo"
  crun [ -d '/tmp/repo/.git' ]
  assert_success
}

@test "git can stage and commit a file" {
  crun bash -c "
    cd /tmp/repo
    git config user.email 'test@test.local'
    git config user.name 'Test'
    echo 'hello' > file.txt
    git add file.txt
    git commit -m 'initial commit'
  "
  assert_success
}

@test "git log shows the commit" {
  crun bash -c "cd /tmp/repo && git log --oneline"
  assert_output --partial 'initial commit'
}
