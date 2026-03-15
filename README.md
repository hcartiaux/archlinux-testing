# Archlinux Testing Suite

Functional testing suite for Arch Linux packages in [*-testing] repositories,
using [bats](https://github.com/bats-core/bats-core) and podman.

## Structure

```
archlinux-testing
├── README.md          # project documentation
├── helpers
│   ├── setup.bash     # shared bats setup
│   ├── container.bash # podman container management
│   └── utils.bash     # general utility functions
├── tests
│   ├── git.bats       # functional tests for git
│   ├── tar.bats       # functional tests for tar
│   ├── openmp.bats    # functional tests for openmp
│   └── ...
└── files
    ├── openmp         # assets for openmp.bats
    └── ...
```

## Requirements

- `podman`
- `bats`
- `bats-support`
- `bats-assert`

## Running

Run all tests:

```bash
$ bats tests/
git.bats

 ✓ Packages:
  📦 git: 2.53.0-1 0
 ✓ git is installed
 ✓ git reports a version
 ✓ git init creates a repository
 ✓ git can stage and commit a file
 ✓ git log shows the commit

openmp.bats

 ✓ Packages:
  📦 openmp: 22.1.1-1 0
  📦 clang: 22.1.1-1 0
 ✓ openmp is installed
 ✓ clang can compile an openmp program
 ✓ compiled program can be executed

tar.bats

 ✓ Packages:
  📦 tar: 1.35-2 0
 ✓ tar is installed
 ✓ tar reports a version
 ✓ tar can create an archive
 ✓ tar can extract an archive
 ✓ extracted file content matches original

13 tests, 0 failures
```

Run a single file:

```bash
$ bats tests/git.bats
git.bats

 ✓ Packages:
  📦 git: 2.53.0-1 0
 ✓ git is installed
 ✓ git reports a version
 ✓ git init creates a repository
 ✓ git can stage and commit a file
 ✓ git log shows the commit

5 tests, 0 failures
```

## How it works

Each `.bats` file gets its own fresh `archlinux:latest` container:

- `$PACKAGES` is a space-separated list of packages to install in the container
- the associated directory under `files` is mapped to `/files`
- instead of using the `run` function of bats, use `crun` to execute commands
  inside the container (current directory is `/files` if available)

This mechanism is implemented inside `helpers/container.bash`, when a file is run:

1. `setup_file` is called:
   - a new container is started with `container_start`
   - `$PACKAGES` are installed
2. `@test` blocks are run
3. `teardown_file` is called
   - the container is stopped and removed

## Adding a new package

1. Place necessary assets, scripts, source code in `tests/<package>`
2. Create `tests/<package>.bats` from a simple test file such as `tar.bats` or `openmp.bats`
3. Update the `$PACKAGES` variable
4. Write `@test` blocks using `crun` to run commands inside the container
