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
# certview - Modular Oh My Zsh Plugin Entry Point
# ------------------------------------------------------------------------------

() {
  local plugin_dir="${${(%):-%x}:A:h}"

  # Source all modular helper and command scripts in lib/
  if [[ -d "${plugin_dir}/lib" ]]; then
    for script in "${plugin_dir}/lib/"*.zsh(N); do
      source "$script"
    done
  fi
}

