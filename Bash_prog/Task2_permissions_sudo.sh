#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Asare Boateng Akuamoah
# @index        7353723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports a file's permissions (symbolic + numeric), changes
#               them with numeric and symbolic chmod, attempts chown only
#               if run as root, and shows before/after permissions.
# @date         2026-09-14
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  path to an existing file to inspect and modify"
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Error: expected exactly 1 argument, got $#." >&2
  usage
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

FILE_PATH="$1"

if [[ ! -e "$FILE_PATH" ]]; then
  echo "Error: '$FILE_PATH' does not exist." >&2
  exit 1
fi
report_permissions() {
  local label="$1"
  local perms_numeric
  local perms_symbolic

  perms_symbolic=$(stat -c '%A' "$FILE_PATH" 2>/dev/null)
  perms_numeric=$(stat -c '%a' "$FILE_PATH" 2>/dev/null)

  if [[ $? -ne 0 || -z "$perms_symbolic" ]]; then
    echo "Error: could not read permissions for '$FILE_PATH' (stat failed)." >&2
    exit 1
  fi

  echo "$label:"
  echo "  Symbolic: $perms_symbolic"
  echo "  Numeric:  $perms_numeric"
}
echo "===== BEFORE ====="
report_permissions "Current permissions"

echo ""
echo "Applying numeric chmod (644)..."
chmod 644 "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Success: applied 'chmod 644'."
else
  echo "Error: 'chmod 644' failed on '$FILE_PATH'." >&2
  exit 1
fi

echo "Applying symbolic chmod (u+x)..."
chmod u+x "$FILE_PATH"
if [[ $? -eq 0 ]]; then
  echo "Success: applied 'chmod u+x'."
else
  echo "Error: 'chmod u+x' failed on '$FILE_PATH'." >&2
  exit 1
fi
CURRENT_UID=$(id -u)
echo ""
if [[ "$CURRENT_UID" -eq 0 ]]; then
  echo "Running as root (uid=0) - attempting chown to root:root..."
  chown root:root "$FILE_PATH"
  if [[ $? -eq 0 ]]; then
    echo "Success: changed ownership of '$FILE_PATH' to root:root."
  else
    echo "Error: chown failed even though running as root." >&2
    exit 1
  fi
else
  echo "Skipped: chown requires root privileges (current uid=$CURRENT_UID)."
  echo "         Re-run this script with 'sudo' if you want to test the chown step."
fi
echo ""
echo "===== AFTER ====="
report_permissions "Updated permissions"

echo ""
echo "Permission demonstration completed successfully."
exit 0

