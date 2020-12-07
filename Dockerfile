FROM apache/airflow:1.10.13-python3.6
ARG GIT_REPO_DIR

USER root

RUN apt-get update \
  && apt-get install pkg-config libicu-dev gcc -yqq \
  && rm -rf /var/lib/apt/lists/*

USER airflow

COPY requirements.build.txt ./requirements.build.txt
RUN  pip install --disable-pip-version-check -r ./requirements.build.txt --user

COPY requirements.txt ./requirements.txt
RUN  pip install --disable-pip-version-check -r ./requirements.txt --user
COPY --chown=airflow:airflow scripts/worker.sh ./
RUN chmod +x worker.sh

COPY --chown=airflow:airflow scripts/install_dag_in_docker.sh ./
COPY --chown=airflow:airflow ${GIT_REPO_DIR} ./${GIT_REPO_DIR}

RUN chmod +x install_dag_in_docker.sh

RUN ./install_dag_in_docker.sh

RUN mkdir -p $AIRFLOW_HOME/serve
RUN ln -s $AIRFLOW_HOME/logs $AIRFLOW_HOME/serve/log
