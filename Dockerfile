FROM puckel/docker-airflow
#dockerfile for airflow image with dask and distributed installed
# Install dependencies
# It's more efficient to do pip install here than adding a requirements.txt
USER root
RUN apt-get update -yqq \
    && pip install dask distributed \
    && pip install 'apache-airflow[google_auth]'

USER airflow
