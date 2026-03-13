# Archlinux Testing Suite

Functional testing suite for Arch Linux [testing] repository packages,
using [bats](https://github.com/bats-core/bats-core) and podman.

## Structure

```
archlinux-testing
├── README.md            # this file
├── helpers
│   ├── container.bash   # shared podman lifecycle helpers
│   └── setup.bash       # shared bats setup helpers
└── tests
    ├── git.bats         # functional tests for git
    ├── tar.bats         # functional tests for tar
    └── ...
```

## Requirements

- `podman`
- `bats`
- `bats-assert`
- `bats-file`

## Running

Run all tests:

```bash
bats tests/
```

Run a single file:

```bash
bats tests/git.bats
```

## How it works

Each `.bats` file gets its own fresh `archlinux:latest` container:

- `$PACKAGES` is a space-separated list of packages to install in the container
- instead of using the `run` function of bats, use `crun` to execute commands
  inside the container

This mechanism is implemented inside `helpers/container.bash`, when a file is run:

1. `setup_file` is called:
   - a new container is started with `container_start`
   - `$PACKAGES` are installed
2. `@test` blocks are run
3. `teardown_file` is called
   - the container is stopped and removed

## Adding a new package

1. Create `tests/<package>.bats` from a simple test file such as `tar.bats`
2. UPDATE the `$PACKAGES` variable
3. Write `@test` blocks using `crun` to run commands inside the container
