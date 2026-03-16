#!/usr/bin/env bash

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

is_file_linked_to() {
  local file="$1"
  local dep="$2"
  local linked_libs

  crun bash -c "
    ldd \"$file\"                      | \
    awk '/=>/ {print \$3}'             | \
    xargs pacman -Qo ${linked_libs[*]} | \
    awk '{print \$(NF-1)}'             | \
    grep \"$dep\"
  "
}

is_pkg_linked_to() {
  local pkg="$1"
  local dep="$2"
  local -a files

  crun bash -c "
      pkg_files=\"\$(pacman -Qlq '$pkg')\"
      {
          grep  -E '^/usr/bin/|\.so$' <<< \"\$pkg_files\"
          grep -vE '^/usr/bin/|\.so$' <<< \"\$pkg_files\"
      } | xargs -I{} sh -c 'test -f \"{}\" && echo \"{}\"'
  "
  mapfile -t files <<< "$output"

  for f in "${files[@]}"; do
    is_file_linked_to "$f" "$dep"
    if [[ $status == 0 ]]; then
      output="$pkg is linked to $dep ($f => $output)"
      status=0
      return
    fi
  done

  output="$pkg is not linked to $dep"
  status=1
}
