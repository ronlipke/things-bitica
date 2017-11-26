#!/bin/bash

# DESCRIPTION
#
# Really simple script to create to-dos in Habitica (https://habitica.com/) from tasks you completed in Things (https://culturedcode.com/things/) within the last 24 hours
#
# REQUIREMENTS
#
# sqlite3 - should be included with macOS, which you're probably using if you're interested in a script for Things
# jo - a nifty shell command to create json in bash scripts with a clever interface because I *hate* wrestling json with bash. Check it out here: http://jpmens.net/2016/03/05/a-shell-command-to-create-json-jo/ or just brew install it
#
# INSTALLATION & SETUP
#
# 1. Put it in your $PATH if you want to invoke it regularly or better yet, create a launch-agent to run it at the same time every day
# 2. Export the HABITICA_API_USER and HABITICA_API_KEY variables with your own values or just hardcode them in the script if you're feeling lazy
#
# WHAT IT DOES
#
# 1. Queries the Things sqlite database at the default location for all tasks you have completed in the last 24 hours
# 2. Formats a JSON request for each completed task
# 3. Makes a call to the Habitica API to create a task with the same name as the Things task, priority of Medium and a note with the date it was created.
#
# NOTES AND WARNINGS
#
# This is super simple and I threw it together in a few minutes.  I definitely plan to improve it or port it to Applescript so it's using a decent interface to Things instead of hitting the sqlite database directly (gross).
# That being said, there's pretty much zero error handling, no flexibility in changing to-do priority to anything other than Medium, doesn't actually complete the task, doesn't keep track of state (ie, if you run it twice it's going to create two sets of to-do's in Habitica) etc etc.
#
# ACKNOWLEDGEMENTS
#
# Thanks to Alexander Willner's original Things3 script (https://github.com/AlexanderWillner/things.sh) for the idea to use sqlite
#
# CREDITS
#
# Author:  Ron Lipke
# Date:    2017-11-25
# License: I don't know, use it at your own discretion

set -u

THINGS_DB=~/Library/Containers/com.culturedcode.ThingsMac/Data/Library/Application\ Support/Cultured\ Code/Things/Things.sqlite3
CYAN="\033[0;36m"
GREEN="\033[0;32m"
GRAY="\033[0;37m"
NC='\033[0m'
# HABITICA_API_USER="your_habitica_user_id"
# HABITICA_API_KEY="your_habitica_api_token"

completed_tasks() {
  sqlite3 "$THINGS_DB" <<-SQL
  SELECT title
  FROM TMTask
  WHERE trashed = 0 AND type = 0
  AND status = 3
  AND stopDate > strftime('%s','now','-24 hours');
SQL
}

create_habitica_tasks() {
  IFS=$'\n'
  tasks="$(completed_tasks)"
  echo -e "${CYAN}List of tasks completed in the last 24 hours from Things:${NC}"
  echo "$tasks"
  for task in $tasks; do
    echo -e "${CYAN}\nCreating the  JSON request for: ${GREEN}$task${NC}"
    task_request=$(jo text=$task type=todo notes="added from Things on $(date +'%Y-%m-%d')" priority=1.5)
    echo -e "${CYAN}It looks like this: ${GRAY}$task_request${NC}"
    echo -e "${CYAN}Habitica responded with this (which may be good or bad, kind of a Schrodinger's cat situation here without any error handling):${NC}"
    curl https://habitica.com/api/v3/tasks/user -d $task_request -s -X POST --compressed -H "Content-Type:application/json" -H "x-api-user: $HABITICA_API_USER" -H "x-api-key: $HABITICA_API_KEY"
  done
}

sqlite3_check() {
  hash sqlite3 2>/dev/null || {
    echo >&2 "ERROR: SQLite3 is required but could not be found."
    exit 1
  }
}

jo_check() {
  hash jo 2>/dev/null || {
    echo >&2 "ERROR: jo is required to create json objects but could not be found."
    exit 1
  }
}

things_db_check() {
  test -r "$THINGS_DB" -a -f "$THINGS_DB" || {
    echo >&2 "ERROR: Things database not found at $THINGS_DB."
    exit 1
  }
}

main() {
  sqlite3_check
  things_db_check
  jo_check
  create_habitica_tasks
}

main
