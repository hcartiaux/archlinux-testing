#!/usr/bin/env bash
# helpers/container.bash — shared podman helpers for the test suite

# Container image
ARCH_IMAGE="archlinux:latest"

# Container timeout
TIMEOUT="60m"

# Temp file (container name)
_CONTAINER_NAME_FILE="${BATS_SUITE_TMPDIR}/container-name"

# Start a container with [testing] repo enabled
container_start() {
  local instance_id="arch-bats-$$-${RANDOM}"
  echo "$instance_id" > "$_CONTAINER_NAME_FILE"

  local project_root
  project_root=$(readlink -f "${BATS_TEST_DIRNAME}/..")

  local test_suite_name
  test_suite_name=$(basename "${BATS_TEST_FILENAME%.*}")

  local host_source_dir="${project_root}/files/${test_suite_name}"
  local container_work_dir="/files"

  # Construct the volume flag only if the source directory exists
  local volume_mount_flag=()
  if [ -d "$host_source_dir" ]; then
    volume_mount_flag=(-v "${host_source_dir}:${container_work_dir}:Z")
  fi

  # Launch the container in the background
  podman run --rm -d          \
    "${volume_mount_flag[@]}" \
    --name "$instance_id"     \
    "$ARCH_IMAGE"             \
    sleep "$TIMEOUT"

  # Enable testing repositories in pacman.conf
  podman exec "$instance_id" sed -i             \
    -e '/^#\[core-testing\]/s/^#//'             \
    -e '/^#\[extra-testing\]/s/^#//'            \
    -e '/^\[core-testing\]/,/^Include/ s/^#//'  \
    -e '/^\[extra-testing\]/,/^Include/ s/^#//' \
    /etc/pacman.conf

  # Sync and upgrade to ensure we are actually using the testing repos
  podman exec "$instance_id" pacman -Syu --noconfirm
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
  if podman exec "$name" test -d /files; then
    run podman exec -w /files "$name" "$@"
  else
    run podman exec "$name" "$@"
  fi
}

# Set-up the testing environment
setup_file() {
  container_start
  crun pacman -S --noconfirm "${PACKAGES[@]}"
}

# Clean-up the testing environment
teardown_file() {
  container_stop
}
