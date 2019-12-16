FROM puckel/docker-airflow
ARG GIT_REPO_DIR

USER root

COPY requirements.root.txt ./requirements.root.txt
RUN  pip install -r ./requirements.root.txt

USER airflow

COPY requirements.txt ./requirements.txt
RUN  pip install -r ./requirements.txt --user
COPY --chown=airflow:airflow scripts/worker.sh ./
RUN chmod +x worker.sh

COPY --chown=airflow:airflow scripts/install_dag_in_docker.sh ./
COPY --chown=airflow:airflow ${GIT_REPO_DIR} ./${GIT_REPO_DIR}

RUN chmod +x install_dag_in_docker.sh

RUN ./install_dag_in_docker.sh

RUN mkdir -p $AIRFLOW_HOME/serve
RUN ln -s $AIRFLOW_HOME/logs $AIRFLOW_HOME/serve/log
