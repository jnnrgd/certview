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
# keyview - Inspect Keys: RSA, ECC, and Ed25519 (PEM & DER)
# ------------------------------------------------------------------------------

keyview() {
  local target=""
  local show_pub=false
  local check_key=false
  local show_text=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--pubkey)      show_pub=true; shift ;;
      -c|--check)       check_key=true; shift ;;
      -t|--text|-a|--all) show_text=true; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: keyview [options] <key-file>

Options:
  -c, --check         Verify key consistency / validity
  -p, --pubkey        Extract and output public key
  -t, --text, -a      Print full key parameters and curve details (default)
  -h, --help          Show this help message
EOF
        return 0
        ;;
      -*)
        print -P "%F{red}Unknown option: $1%f" >&2
        return 1
        ;;
      *)
        target="$1"
        shift
        ;;
    esac
  done

  _certview_validate_file "$target" "keyview" || return 1
  local form="$(_certview_detect_format "$target")"

  # Detect whether input is public or private key
  local is_pub=false
  if grep -q -- "-----BEGIN PUBLIC KEY-----" "$target" 2>/dev/null || \
     grep -q -- "-----BEGIN RSA PUBLIC KEY-----" "$target" 2>/dev/null; then
    is_pub=true
  fi

  if [[ "$check_key" == true ]]; then
    if [[ "$is_pub" == true ]]; then
      print -P "%F{yellow}Integrity check (-c) applies to private keys. Validating structure...%f"
      openssl pkey -pubin -inform "$form" -in "$target" -noout >/dev/null 2>&1 \
        && print -P "%F{green}✔ Public key structure is valid.%f" \
        || print -P "%F{red}✘ Invalid public key file.%f"
    else
      openssl pkey -inform "$form" -in "$target" -check -noout 2>/dev/null \
        && print -P "%F{green}✔ Key integrity check passed.%f" \
        || print -P "%F{red}✘ Key check failed or key is malformed.%f"
    fi
  fi

  if [[ "$show_pub" == true ]]; then
    if [[ "$is_pub" == true ]]; then
      openssl pkey -pubin -inform "$form" -in "$target"
    else
      openssl pkey -inform "$form" -in "$target" -pubout
    fi
    return $?
  fi

  if [[ "$show_text" == true || ("$check_key" == false && "$show_pub" == false) ]]; then
    print -P "%F{cyan}--> Viewing $form Key parameters ($target):%f"
    if [[ "$is_pub" == true ]]; then
      openssl pkey -pubin -inform "$form" -in "$target" -text -noout
    else
      openssl pkey -inform "$form" -in "$target" -text -noout
    fi
  fi
}
