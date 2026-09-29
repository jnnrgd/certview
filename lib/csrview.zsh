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
# csrview - Inspect Certificate Signing Requests (PEM & DER)
# ------------------------------------------------------------------------------

csrview() {
  local target=""
  local show_all=true
  local show_san=false
  local -a req_opts

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--subject)     req_opts+=("-subject"); show_all=false; shift ;;
      -p|--pubkey)      req_opts+=("-pubkey"); show_all=false; shift ;;
      -v|--verify)      req_opts+=("-verify"); show_all=false; shift ;;
      -m|--modulus)     req_opts+=("-modulus"); show_all=false; shift ;;
      -n|--san)         show_san=true; show_all=false; shift ;;
      -t|--text|-a|--all) show_all=true; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: csrview [options] <csr-file>

Options:
  -s, --subject       Print subject DN
  -n, --san           Print requested Subject Alternative Names (SAN)
  -p, --pubkey        Print public key
  -m, --modulus       Print key modulus (RSA)
  -v, --verify        Verify self-signature on CSR
  -t, --text, -a      Print full decoded CSR (default)
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

  _certview_validate_file "$target" "csrview" || return 1
  local form="$(_certview_detect_format "$target")"

  if [[ "$show_san" == true ]]; then
    print -P "%F{cyan}--> Requested SANs in CSR:%f"
    openssl req -inform "$form" -in "$target" -noout -text | grep -A1 "Subject Alternative Name:"
  fi

  if [[ ${#req_opts[@]} -gt 0 ]]; then
    openssl req -inform "$form" -in "$target" -noout "${req_opts[@]}"
    return $?
  fi

  if [[ "$show_all" == true && "$show_san" == false ]]; then
    print -P "%F{cyan}--> Decoding $form CSR: $target%f"
    openssl req -inform "$form" -in "$target" -text -noout -verify
  fi
}
