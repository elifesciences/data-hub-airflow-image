FROM puckel/docker-airflow
ARG GIT_REPO_DIR

#dockerfile for airflow image with dask and distributed installed
# Install dependencies

USER root
RUN apt-get update -yqq \
    && pip install dask distributed \
    && pip install 'apache-airflow[google_auth]'

USER airflow

COPY --chown=airflow:airflow scripts/worker.sh ./
RUN chmod +x worker.sh

COPY --chown=airflow:airflow scripts/install_dag_in_docker.sh ./
COPY --chown=airflow:airflow ${GIT_REPO_DIR} ./${GIT_REPO_DIR}

RUN chmod +x install_dag_in_docker.sh

RUN ./install_dag_in_docker.sh

RUN mkdir -p $AIRFLOW_HOME/serve
RUN ln -s $AIRFLOW_HOME/logs $AIRFLOW_HOME/serve/log
