#!/usr/bin/env bash
# helpers/container.bash — shared podman helpers for the test suite

# Container image
ARCH_IMAGE="archlinux:latest"

# Container timeout
TIMEOUT="60m"

# Temp file (container name)
_CONTAINER_NAME_FILE="${BATS_SUITE_TMPDIR}/container-name-${PACKAGES}"

# Start a container with [testing] repo enabled
container_start() {
  local name="arch-bats-$$-${RANDOM}"
  echo "$name" > "$_CONTAINER_NAME_FILE"

  podman run --rm -d --name "$name" "$ARCH_IMAGE" sleep $TIMEOUT

  podman exec "$name" sed -i \
   -e '/^#\[core-testing\]/s/^#//' \
   -e '/^#\[extra-testing\]/s/^#//' \
   -e '/^\[core-testing\]/,/^Include/ s/^#//' \
   -e '/^\[extra-testing\]/,/^Include/ s/^#//' \
   /etc/pacman.conf

  podman exec "$name" pacman -Syu --noconfirm
}

# Stop the container
container_stop() {
  local name
  name="$(cat "$_CONTAINER_NAME_FILE" 2>/dev/null)"
  if [[ -n "$name" ]]; then
    podman rm -f "$name" >/dev/null 2>&1
    rm -f "$_CONTAINER_NAME_FILE"
  fi
}

# Run a command inside the current container
crun() {
  local name
  name="$(cat "$_CONTAINER_NAME_FILE")"
  run podman exec "$name" "$@"
}

# Install packages inside the current container
cpacman() {
  crun pacman -S --noconfirm "$@"
}

# Set-up the testing environment
setup_file() {
  container_start
  cpacman "$PACKAGES"
}

# Clean-up the testing environment
teardown_file() {
  container_stop
}
