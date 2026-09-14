#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Asare Boateng Akuamoah
# @index        7353723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability, disk
#               space, file existence, command availability), exiting with
#               a specific documented code on the first failure. Cleans up
#               temp files via trap regardless of how the script exits.
# @date         2026-09-14
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  a host to ping-check, e.g. google.com"
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Error: expected exactly 1 argument, got $#." >&2
  usage
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

HOST="$1"
TMP_FILE=$(mktemp /tmp/task4_check.XXXXXX)

cleanup() {
  echo "Cleaning up temporary file '$TMP_FILE'..."
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

check_status() {
  local result="$1"
  local success_msg="$2"
  local fail_msg="$3"
  local fail_exit_code="$4"

  if [[ "$result" -eq 0 ]]; then
    echo "PASS: $success_msg"
  else
    echo "FAIL: $fail_msg" >&2
    exit "$fail_exit_code"
  fi
}
echo "Running system checks for host: $HOST"
echo ""

# ---- Check 1: is the host reachable? --------------------------------------
ping -c 1 -W 2 "$HOST" > "$TMP_FILE" 2>&1
check_status $? \
  "host '$HOST' is reachable." \
  "host '$HOST' is unreachable." \
  2

# ---- Check 2: is there enough free disk space? -----------------------------
# We check that root filesystem usage is below 90% - df's "Use%" column.
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ "$DISK_USAGE" -lt 90 ]]; then
  DISK_CHECK_RESULT=0
else
  DISK_CHECK_RESULT=1
fi
check_status "$DISK_CHECK_RESULT" \
  "disk usage is at ${DISK_USAGE}%, within acceptable limits." \
  "disk usage is at ${DISK_USAGE}%, too high." \
  3

# ---- Check 3: does a required config/data file exist and is readable? -----
REQUIRED_FILE="/etc/hostname"
[[ -r "$REQUIRED_FILE" ]]
check_status $? \
  "required file '$REQUIRED_FILE' exists and is readable." \
  "required file '$REQUIRED_FILE' not found or not readable." \
  4

# ---- Check 4: is a required command/tool installed? ------------------------
REQUIRED_CMD="curl"
command -v "$REQUIRED_CMD" > /dev/null 2>&1
check_status $? \
  "required command '$REQUIRED_CMD' is installed." \
  "required command '$REQUIRED_CMD' is not installed." \
  5

echo ""
echo "All checks passed."
exit 0

