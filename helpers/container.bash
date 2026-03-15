#!/usr/bin/env bash
# Shared podman helpers for the test suite

# Container image
ARCH_IMAGE="archlinux:latest"

# Container timeout
TIMEOUT="3600"

# Temp file (contains the running container name)
_CONTAINER_NAME_FILE="${BATS_SUITE_TMPDIR}/container-name"

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

# Start a container with [testing] repos enabled
container_start() {
  local instance_id="arch-bats-$$-${RANDOM}"
  echo "$instance_id" > "$_CONTAINER_NAME_FILE"

  local project_root
  project_root=$(readlink -f "${BATS_TEST_DIRNAME}/..")

  local test_suite_name
  test_suite_name=$(basename "${BATS_TEST_FILENAME%.*}")

  local host_source_dir="${project_root}/files/${test_suite_name}"
  local container_work_dir="/files"

  # Construct the volume mapping parameter
  local volume_mount_flag=()
  if [ -d "$host_source_dir" ]; then
    volume_mount_flag=(-v "${host_source_dir}:${container_work_dir}:ro,Z")
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
  fi
}

# Run a command inside the current container
crun() {
  local name
  name="$(cat "$_CONTAINER_NAME_FILE" 2>/dev/null)"
  if podman exec "$name" test -d /files; then
    run podman exec -w /files "$name" "$@"
  else
    run podman exec "$name" "$@"
  fi
}

install_packages() {
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

  if [[ ${#PACKAGES[@]} -gt 0 ]]; then
    crun pacman -S --noconfirm "${PACKAGES[@]}"
    [ "$status" -ne 0 ] && fail "Failed to install packages: ${PACKAGES[*]}"
  fi
  success "Packages:"
  for pkg in "${PACKAGES[@]}"; do
    crun bash -c "pacman -Qi ${pkg} | awk '/^Version/ {print \$3}'"
    echo "  📦 ${pkg}: ${output} $status" >&3
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
