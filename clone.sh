#!/bin/sh -e

REPO_FILE=$1
MAIN_GIT_REPO_DIR=$2


if [ ! -d $MAIN_GIT_REPO_DIR ]; then
      mkdir -p $MAIN_GIT_REPO_DIR
fi

rm -rf $MAIN_GIT_REPO_DIR\/*


for row in $(jq -c '.[]' $REPO_FILE ); do
    _jq() {
     echo ${row} | jq -r ${1}
    }
  git clone $(_jq '.git_repo_url') "$MAIN_GIT_REPO_DIR/$(_jq '.clone_directory')"
  cd "$MAIN_GIT_REPO_DIR/$(_jq '.clone_directory')"
    git reset --hard $(_jq '.reference')
    cd ../../
done
