FROM apache/airflow:2.3.0-python3.7
ARG GIT_REPO_DIR

USER root

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

RUN apt-get update \
  && apt-get install pkg-config libicu-dev gcc g++ -yqq \
  && rm -rf /var/lib/apt/lists/*

USER airflow

COPY requirements.build.txt ./requirements.build.txt
RUN  pip install --disable-pip-version-check -r ./requirements.build.txt --user

COPY requirements.txt ./requirements.txt
RUN  pip install --disable-pip-version-check -r ./requirements.txt --user

COPY scripts/install_dag_in_docker.sh ./
COPY ${GIT_REPO_DIR} ./${GIT_REPO_DIR}

RUN ./install_dag_in_docker.sh

RUN mkdir -p $AIRFLOW_HOME/serve
RUN ln -s $AIRFLOW_HOME/logs $AIRFLOW_HOME/serve/log
