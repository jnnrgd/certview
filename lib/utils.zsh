# Written in 2026 by jnnrgd
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain worldwide.
# This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
#
# SPDX-License-Identifier: CC0-1.0
# ------------------------------------------------------------------------------
# certview - Shared Helper Functions
# ------------------------------------------------------------------------------

# Detect whether a target file is PEM or DER encoded
_certview_detect_format() {
  local file="$1"
  if grep -q -- "-----BEGIN " "$file" 2>/dev/null; then
    echo "PEM"
  else
    echo "DER"
  fi
}

# Validate file presence before parsing
_certview_validate_file() {
  local file="$1"
  local cmd_name="$2"

  if [[ -z "$file" ]]; then
    print -P "%F{red}Error:%f No target file specified. Use '${cmd_name} -h' for usage." >&2
    return 1
  fi

  if [[ ! -f "$file" ]]; then
    print -P "%F{red}Error:%f File not found: ${file}" >&2
    return 1
  fi

  return 0
}

