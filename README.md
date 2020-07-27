# eLife's Data Hub  Airflow Image
Create custom airflow image which is deployed in K8s and used for running data hub data pipelines.
The image created contains a set of airflow dag which are installed in the image after their git repos (listed in the `repo-list.json`) are cloned and copied into the docker image.
#### How the image is created
The `clone.sh` clones each of the git repos specified in the `repo-list.json` file into the directory specified for the particular repo 
in the `repo-list.json`.
During the image build, 
 - The cloned git repos are copied over into the docker image, as well as the scripts in `scripts`.
 - The script `scripts/install_dag_in_docker.sh` recursively invokes the `install.sh` scripts in the root directory of each of the cloned data pipeline git repos. 
 The `install.sh` in each of the cloned git repos should 
   - Install the required python packages for the data pipeline
   - Copy over the  dags files into appropriate dags directory,  
   - Copy over the data pipeline application files to the appropriate directory
    - install the cloned data pipeline application as a python package
 - The `scripts/worker.sh` is used to create web server  that can be used to serve log files created by airflow task execution workers.
 This should be run when the worker pod/docker container is created
 
 #### CI/CD
Points to note:
- Every merge to the dev creates and pushes an image to the docker hub. 
- It also triggers another CI pipeline that re-deploys the running data-hub application in the staging environment using this latest created image
- To create and deploy an image into data hub production environment, create a release of the github repo.
- The git commit ref for each of the repo in the repo list is typically updated by another CI pipeline which is expected to be invoked whenever there is a merge to `develop` branch in each of the  data pipelines git repos.
