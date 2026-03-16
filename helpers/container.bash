#!/usr/bin/env bash
# Shared podman helpers for the test suite

# Container image
ARCH_IMAGE="archlinux:latest"

# Container timeout
TIMEOUT="3600"

# Package being tested
_TARGET="$(basename "${BATS_TEST_FILENAME}" .bats)"

# Temp file (contains the running container name and work directory)
_CONTAINER_NAME_FILE="${BATS_SUITE_TMPDIR}/container-name"
_CONTAINER_WORK_DIR="${BATS_SUITE_TMPDIR}/container-work-dir"

# Start a container with [testing] repos enabled
container_start() {
  local instance_id="arch-bats-$$-${RANDOM}"
  echo "$instance_id" > "$_CONTAINER_NAME_FILE"

  local project_root
  project_root=$(readlink -f "${BATS_TEST_DIRNAME}/..")

  local host_source_dir="${project_root}/files/${_TARGET}"
  local container_work_dir="/files"

  # Construct the volume mapping parameter
  local volume_mount_flag=()
  if [ -d "$host_source_dir" ]; then
    echo $container_work_dir > "$_CONTAINER_WORK_DIR"
    volume_mount_flag=(-v "${host_source_dir}:${container_work_dir}:ro,Z")
  else
    echo /tmp/ > "$_CONTAINER_WORK_DIR"
  fi

  # Launch the container in the background
  if ! podman run --rm -d      \
    "${volume_mount_flag[@]}" \
    --name "$instance_id"     \
    "$ARCH_IMAGE"             \
    sleep "$TIMEOUT"; then
    fail "Failed to start container $instance_id ($ARCH_IMAGE)"
  fi
}

# Stop the container
container_stop() {
  local name
  name="$(cat "$_CONTAINER_NAME_FILE" 2>/dev/null)"
  if [[ -n "$name" ]]; then
    podman rm -f "$name" >/dev/null 2>&1 || true
    rm -f "$_CONTAINER_NAME_FILE"
    rm -f "$_CONTAINER_WORK_DIR"
  fi
}

# Run a command inside the current container
crun() {
  local name
  name="$(cat "$_CONTAINER_NAME_FILE" 2>/dev/null)"
  local container_work_dir
  container_work_dir="$(cat "$_CONTAINER_WORK_DIR" 2>/dev/null)"
  run podman exec -w "$container_work_dir" "$name" "$@"
}

install_packages() {
  local -a packages
  packages+=("$(basename "${BATS_TEST_FILENAME}" .bats)")
  packages+=("${DEPENDS[@]}")

  # Enable testing repositories in pacman.conf
  crun sed -i                                   \
    -e '/^#\[core-testing\]/s/^#//'             \
    -e '/^#\[extra-testing\]/s/^#//'            \
    -e '/^\[core-testing\]/,/^Include/ s/^#//'  \
    -e '/^\[extra-testing\]/,/^Include/ s/^#//' \
    /etc/pacman.conf
  [ "$status" -ne 0 ] && fail "Failed to enable testing repositories"

  # Sync and upgrade to ensure we are actually using the testing repos
  crun pacman -Syu --noconfirm
  [ "$status" -ne 0 ] && fail "Failed to sync and upgrade packages"

  if [[ ${#packages[@]} -gt 0 ]]; then
    crun pacman -S --noconfirm "${packages[@]}"
    [ "$status" -ne 0 ] && fail "Failed to install packages: ${packages[*]}"
  fi
  success "Package list:"
  for pkg in "${packages[@]}"; do
    crun bash -c "pacman -Qi ${pkg} | awk '/^Version/ {print \$3}'"
    echo "  📦 ${pkg}: ${output}" >&3
  done
}

# Set-up the testing environment
setup_file() {
  container_start
  install_packages
}

# Clean-up the testing environment
teardown_file() {
  container_stop
  newline
}
