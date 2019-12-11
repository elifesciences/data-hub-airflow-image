FROM puckel/docker-airflow
#dockerfile for airflow image with dask and distributed installed
# Install dependencies
# It's more efficient to do pip install here than adding a requirements.txt
USER root
RUN apt-get update -yqq \
    && pip install dask distributed \
    && pip install 'apache-airflow[google_auth]'

USER airflow

COPY --chown=airflow:airflow worker.sh ./
RUN chmod +x worker.sh

RUN mkdir -p $AIRFLOW_HOME/serve
RUN ln -s $AIRFLOW_HOME/logs $AIRFLOW_HOME/serve/log
