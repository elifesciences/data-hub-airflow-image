# datahub-airflow
Create custom airflow image used for running data-hub pipelines.
The image created contains a set of airflow dag which are installed in the image after their git repos (as specified in the `repo-list.json` are cloned and copied into the docker image.

