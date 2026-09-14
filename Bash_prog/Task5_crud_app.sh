#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Asare Boateng Akuamoah
# @index        7353723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven Todo list CRUD app. Stores tasks as CSV
#               (id,description,status) in todos.csv next to the script.
#               Backs up data before destructive changes.
# @date         2026-09-14
# -----------------------------------------------------------------

set -u

DATA_FILE="todos.csv"
BACKUP_FILE="todos.csv.bak"

usage() {
  echo "Usage: $0"
  echo "  Runs an interactive Todo list menu. No arguments needed."
  echo "  Data is stored in '$DATA_FILE' next to this script."
  exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

if [[ ! -f "$DATA_FILE" ]]; then
  touch "$DATA_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Info: created new data file '$DATA_FILE'."
  else
    echo "Error: could not create data file '$DATA_FILE'." >&2
    exit 1
  fi
fi
next_id() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo 1
    return
  fi
  local max_id
  max_id=$(cut -d',' -f1 "$DATA_FILE" | sort -n | tail -1)
  echo $((max_id + 1))
}

add_todo() {
  local description
  local id

  read -rp "Enter task description: " description

  if [[ -z "$description" ]]; then
    echo "Error: description cannot be empty. Task not added." >&2
    return 1
  fi

  id=$(next_id)
  echo "${id},${description},pending" >> "$DATA_FILE"

  if [[ $? -eq 0 ]]; then
    echo "Success: added task #$id - \"$description\" (pending)."
  else
    echo "Error: failed to write new task to '$DATA_FILE'." >&2
    return 1
  fi
}
view_todos() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks yet."
    return
  fi

  printf "%-5s %-40s %-10s\n" "ID" "DESCRIPTION" "STATUS"
  printf "%-5s %-40s %-10s\n" "--" "-----------" "------"

  while IFS=',' read -r id description status; do
    printf "%-5s %-40s %-10s\n" "$id" "$description" "$status"
  done < "$DATA_FILE"
}

search_todos() {
  local term

  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks yet."
    return
  fi

  read -rp "Enter search term (matches description): " term

  if [[ -z "$term" ]]; then
    echo "Error: search term cannot be empty." >&2
    return 1
  fi

  local matches
  matches=$(grep -i "$term" "$DATA_FILE")

  if [[ -z "$matches" ]]; then
    echo "No tasks found matching '$term'."
  else
    printf "%-5s %-40s %-10s\n" "ID" "DESCRIPTION" "STATUS"
    echo "$matches" | while IFS=',' read -r id description status; do
      printf "%-5s %-40s %-10s\n" "$id" "$description" "$status"
    done
  fi
}
backup_data() {
  cp "$DATA_FILE" "$BACKUP_FILE"
  if [[ $? -eq 0 ]]; then
    echo "Info: backed up '$DATA_FILE' to '$BACKUP_FILE' before making changes."
  else
    echo "Error: backup failed - aborting to avoid risking data loss." >&2
    return 1
  fi
}

update_todo() {
  local target_id
  local new_status

  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks yet."
    return
  fi

  read -rp "Enter task ID to update: " target_id

  if ! grep -q "^${target_id}," "$DATA_FILE"; then
    echo "Error: task #$target_id not found." >&2
    return 1
  fi

  read -rp "Enter new status (pending/done): " new_status
  if [[ "$new_status" != "pending" && "$new_status" != "done" ]]; then
    echo "Error: status must be 'pending' or 'done'." >&2
    return 1
  fi

  backup_data || return 1

  awk -F',' -v id="$target_id" -v status="$new_status" \
    'BEGIN{OFS=","} $1==id {$3=status} {print}' "$DATA_FILE" > "${DATA_FILE}.tmp" \
    && mv "${DATA_FILE}.tmp" "$DATA_FILE"

  if [[ $? -eq 0 ]]; then
    echo "Success: task #$target_id updated to '$new_status'."
  else
    echo "Error: failed to update task #$target_id." >&2
    return 1
  fi
}

delete_todo() {
  local target_id
  local confirm

  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks yet."
    return
  fi

  read -rp "Enter task ID to delete: " target_id

  if ! grep -q "^${target_id}," "$DATA_FILE"; then
    echo "Error: task #$target_id not found." >&2
    return 1
  fi

  read -rp "Are you sure you want to delete task #$target_id? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled: task #$target_id was not deleted."
    return
  fi

  backup_data || return 1

  grep -v "^${target_id}," "$DATA_FILE" > "${DATA_FILE}.tmp" \
    && mv "${DATA_FILE}.tmp" "$DATA_FILE"

  if [[ $? -eq 0 ]]; then
    echo "Success: task #$target_id deleted."
  else
    echo "Error: failed to delete task #$target_id." >&2
    return 1
  fi
}
show_menu() {
  echo ""
  echo "===== Todo List Menu ====="
  echo "1) Add task"
  echo "2) View all tasks"
  echo "3) Search tasks"
  echo "4) Update task status"
  echo "5) Delete task"
  echo "6) Exit"
  echo "==========================="
}

while true; do
  show_menu
  read -rp "Choose an option (1-6): " choice

  case "$choice" in
    1)
      add_todo
      ;;
    2)
      view_todos
      ;;
    3)
      search_todos
      ;;
    4)
      update_todo
      ;;
    5)
      delete_todo
      ;;
    6)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Error: invalid option '$choice'. Please choose 1-6." >&2
      ;;
  esac
done

