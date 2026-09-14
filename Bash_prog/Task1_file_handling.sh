#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Asare Boateng Akuamoah
# @index        7353723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Demonstrates file handling: create dir/file, write, append,
#               read, backup, and safe delete - checking each step succeeds.
# @date         2026-09-14
# -----------------------------------------------------------------


usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory>  path to a directory to create/use for this demo"
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Error: expected exactly 1 argument, got $#." >&2
  usage
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

TARGET_DIR="$1"
DEMO_FILE="$TARGET_DIR/demo.txt"
BACKUP_FILE="$DEMO_FILE.bak"
if [[ -d "$TARGET_DIR" ]]; then
  echo "Info: directory '$TARGET_DIR' already exists."
else
  mkdir -p "$TARGET_DIR"
  if [[ $? -eq 0 ]]; then
    echo "Success: created directory '$TARGET_DIR'."
  else
    echo "Error: failed to create directory '$TARGET_DIR' (check permissions)." >&2
    exit 1
  fi
fi
echo "This is the first line of the demo file." > "$DEMO_FILE"
if [[ $? -eq 0 ]]; then
  echo "Success: created '$DEMO_FILE' and wrote initial content."
else
  echo "Error: could not write to '$DEMO_FILE'." >&2
  exit 1
fi

echo "This line was appended afterwards." >> "$DEMO_FILE"
if [[ $? -eq 0 ]]; then
  echo "Success: appended content to '$DEMO_FILE'."
else
  echo "Error: append to '$DEMO_FILE' failed." >&2
  exit 1
fi
if [[ -r "$DEMO_FILE" ]]; then
  echo "----- Contents of $DEMO_FILE -----"
  cat "$DEMO_FILE"
  echo "-----------------------------------"
else
  echo "Error: '$DEMO_FILE' is not readable." >&2
  exit 1
fi
cp "$DEMO_FILE" "$BACKUP_FILE"
if [[ $? -eq 0 ]]; then
  echo "Success: backed up file to '$BACKUP_FILE'."
else
  echo "Error: backup copy to '$BACKUP_FILE' failed." >&2
  exit 1
fi
if [[ -f "$DEMO_FILE" ]]; then
  echo "Confirming: '$DEMO_FILE' exists and will now be deleted (backup is safe at '$BACKUP_FILE')."
  rm "$DEMO_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Success: deleted '$DEMO_FILE'."
  else
    echo "Error: failed to delete '$DEMO_FILE'." >&2
    exit 1
  fi
else
  echo "Error: '$DEMO_FILE' does not exist, nothing to delete." >&2
  exit 1
fi

echo "All file handling steps completed successfully."
exit 0
