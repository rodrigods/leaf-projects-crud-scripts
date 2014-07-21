#!/bin/bash

KEYSTONE_HOST=${KEYSTONE_HOST:-localhost}

function check_token_set() {
  if [ -z "$TOKEN" ]; then
    echo "ERROR WHILE RETRIEVING TOKEN"
    exit 1
  else
    echo "TOKEN SUCCESSFULLY RETRIEVED"
  fi
}

function create_root_project() {
  local NAME=$1

  PROJ=$(curl -s -H "X-Auth-Token:$TOKEN" -H "Content-type: application/json" \
         -d '{"project": {"description": "--optional--", "name": "'"$NAME"'"}}' \
         http://$KEYSTONE_HOST:5000/v3/projects)
  echo $PROJ
}

function create_leaf_project() {
  local NAME=$1
  local PARENT_ID=$2

  PROJ=$(curl -s -H "X-Auth-Token:$TOKEN" -H "Content-type: application/json" \
         -d '{"project": {"description": "--optional--", "name": "'"$NAME"'", "parent_project_id": "'"$PARENT_ID"'"}}' \
         http://$KEYSTONE_HOST:5000/v3/projects)
  echo $PROJ
}

function update_parent() {
  local ID=$1
  local NEW_PARENT_ID=$2

  local OLD_DATA=$(curl -s -H "X-Auth-Token: $TOKEN" http://$KEYSTONE_HOST:5000/v3/projects/$ID)
  echo "$OLD_DATA"
  local NEW_DATA=$(echo $OLD_DATA | jq ".project.parent_project_id|=\"$NEW_PARENT_ID\"")

  curl -s -H "X-Auth-Token: $TOKEN" -H "Content-type: application/json" \
       -X PATCH -d "$NEW_DATA" \
       http://$KEYSTONE_HOST:5000/v3/projects/$ID
}

function delete_project() {
  local ID=$1

  # Disable project
  local OLD_DATA=$(curl -s -H "X-Auth-Token: $TOKEN" http://$KEYSTONE_HOST:5000/v3/projects/$ID)
  local NEW_DATA=$(echo $OLD_DATA | jq '.project.enabled|=false')

  curl -s -H "X-Auth-Token: $TOKEN" -H "Content-type: application/json" \
       -X PATCH -d "$NEW_DATA" \
       http://$KEYSTONE_HOST:5000/v3/projects/$ID > /dev/null

  # Delete project
  curl -s -H "X-Auth-Token: $TOKEN" -H "Content-type: application/json" \
       -X DELETE \
       http://$KEYSTONE_HOST:5000/v3/projects/$ID
}

