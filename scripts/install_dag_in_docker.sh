#!/bin/sh

set -e

DAGS_PATH=$AIRFLOW_HOME/dags
REPOS_DIR=$AIRFLOW_HOME/git_repos

if [ ! -d $DAGS_PATH ]; then
  mkdir -p $DAGS_PATH
fi

cd $REPOS_DIR

for dag_dir in */ ; do
  if [ -f $dag_dir/install.sh ]; then
    $dag_dir/install.sh $DAGS_PATH
  elif [ -f $dag_dir/requirements.txt ]; then
    pip install --user -r $dag_dir/requirements.txt
    cp $dag_dir $DAGS_PATH -r
  fi
done
