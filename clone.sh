#!/bin/sh -e

REPO_FILE=$1
MAIN_GIT_REPO_DIR=$2


if [ ! -d $MAIN_GIT_REPO_DIR ]; then
      mkdir -p $MAIN_GIT_REPO_DIR
fi

rm -rf $MAIN_GIT_REPO_DIR\/*

while IFS=, read -r git_repo ref directory
do
    git clone $git_repo "$MAIN_GIT_REPO_DIR/$directory"
    cd "$MAIN_GIT_REPO_DIR/$directory"
    git reset --hard $ref
    cd ../../
done < $REPO_FILE