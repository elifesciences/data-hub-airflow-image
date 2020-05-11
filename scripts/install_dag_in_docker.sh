#!/bin/sh

set -e

DAGS_PATH=$AIRFLOW_HOME/dags
REPOS_DIR=$AIRFLOW_HOME/git_repos
APP_FILES_DIR=$AIRFLOW_HOME/auxiliary_data_pipeline_files

if [ ! -d $DAGS_PATH ]; then
  mkdir -p $DAGS_PATH
fi

if [ ! -d $APP_FILES_DIR ]; then
  mkdir -p $APP_FILES_DIR
fi

cd $REPOS_DIR

for dag_dir in */ ; do
  if [ -f $dag_dir/install.sh ]; then
    $dag_dir/install.sh $DAGS_PATH $APP_FILES_DIR
  elif [ -f $dag_dir/requirements.txt ]; then
    pip install --user -r $dag_dir/requirements.txt
    cp $dag_dir $DAGS_PATH -r
  fi
done
