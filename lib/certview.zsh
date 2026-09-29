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
# certview - Inspect X.509 Certificates (PEM & DER)
# ------------------------------------------------------------------------------

certview() {
  local target=""
  local show_all=true
  local check_expired=false
  local show_san=false
  local -a x509_opts

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--subject)     x509_opts+=("-subject"); show_all=false; shift ;;
      -i|--issuer)      x509_opts+=("-issuer"); show_all=false; shift ;;
      -d|--dates)       x509_opts+=("-dates"); show_all=false; shift ;;
      -f|--fingerprint) x509_opts+=("-fingerprint" "-sha256"); show_all=false; shift ;;
      --serial)         x509_opts+=("-serial"); show_all=false; shift ;;
      -m|--modulus)     x509_opts+=("-modulus"); show_all=false; shift ;;
      -p|--pubkey)      x509_opts+=("-pubkey"); show_all=false; shift ;;
      -n|--san)         show_san=true; show_all=false; shift ;;
      -c|--check)       check_expired=true; show_all=false; shift ;;
      -t|--text|-a|--all) show_all=true; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: certview [options] <certificate-file>

Options:
  -s, --subject       Print subject DN
  -i, --issuer        Print issuer DN
  -d, --dates         Print notBefore and notAfter dates
  -f, --fingerprint   Print SHA-256 fingerprint
  -n, --san           Print Subject Alternative Names (SAN)
  --serial            Print serial number
  -p, --pubkey        Print public key
  -m, --modulus       Print key modulus
  -c, --check         Verify if certificate is expired or valid now
  -t, --text, -a      Print full decoded certificate (default)
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

  _certview_validate_file "$target" "certview" || return 1
  local form="$(_certview_detect_format "$target")"

  if [[ "$check_expired" == true ]]; then
    if openssl x509 -inform "$form" -in "$target" -noout -checkend 0 >/dev/null 2>&1; then
      print -P "%F{green}✔ Certificate is currently valid (not expired).%f"
    else
      print -P "%F{red}✘ Certificate is EXPIRED or not yet valid.%f"
    fi
  fi

  if [[ "$show_san" == true ]]; then
    print -P "%F{cyan}--> Subject Alternative Names (SAN):%f"
    openssl x509 -inform "$form" -in "$target" -noout -ext subjectAltName 2>/dev/null || \
      openssl x509 -inform "$form" -in "$target" -noout -text | grep -A1 "Subject Alternative Name:"
  fi

  if [[ ${#x509_opts[@]} -gt 0 ]]; then
    openssl x509 -inform "$form" -in "$target" -noout "${x509_opts[@]}"
    return $?
  fi

  if [[ "$show_all" == true && "$check_expired" == false && "$show_san" == false ]]; then
    print -P "%F{cyan}--> Decoding $form Certificate: $target%f"
    openssl x509 -inform "$form" -in "$target" -text -noout
  fi
}

