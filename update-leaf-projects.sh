#!/bin/bash

source utils.sh

# Create Token
source export-token.sh
check_token_set
echo ""

# Create root projects
echo "CREATING root_project_1"
ROOT1=$(create_root_project "root1")
ROOT1_ID=$(echo $ROOT1 | jq '.project.id' -r)
echo "ROOT1: $ROOT1"
echo ""

echo "CREATING root_project_2"
ROOT2=$(create_root_project "root2")
ROOT2_ID=$(echo $ROOT2 | jq '.project.id' -r)
echo "ROOT2: $ROOT2"
echo ""

# Create leaf project (under root_project_1)
echo "CREATING leaf_project"
LEAF=$(create_leaf_project "leaf" $ROOT1_ID)
LEAF_ID=$(echo $LEAF | jq '.project.id' -r)
echo "LEAF: $LEAF"
echo ""

# Try to update root_project_1 parent
echo "UPDATING root_project_1 parent to root_project_2"
update_parent $ROOT1_ID $ROOT2_ID
echo ""

# Update leaf_project parent to root_project_2
echo "UPDATING leaf_project parent to root_project_2"
update_parent $LEAF_ID $ROOT2_ID
echo ""

# Delete everything
echo "Deleting leaf project"
delete_project $LEAF_ID
echo "Deleting root project 1"
delete_project $ROOT1_ID
echo "Deleting root project 2"
delete_project $ROOT2_ID
