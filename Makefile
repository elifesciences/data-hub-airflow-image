#!/usr/bin/make -f

# variables for creating docker image
GIT_REPOS_DIR_NAME = git_repos
REPO_LIST_FILEx = unstable-image-repo-list.json
REPO_LIST_FILE = repo-list2.json

IMAGE_REPO = elifesciences/data-hub-with-dags
IMAGE_TAG = develop

GIT_URL_TO_UPDATE = git@github.com:elifesciences/data-hub-core-airflow-dags.git
NEW_GIT_URL_REF = "updated_ref"


COMPOSED_MAKEFILE_ARG = DEPLOYMENT_ENV=$(DEPLOYMENT_ENV)  DEPLOYMENT_NAMESPACE=$(DEPLOYMENT_NAMESPACE) IMAGE_REPO=$(IMAGE_REPO) IMAGE_TAG=$(IMAGE_TAG)

update-repo-list:
	echo $$(jq  --arg giturl $(GIT_URL_TO_UPDATE)  --arg ref  $(NEW_GIT_URL_REF) -c '. | map( if .git_repo_url == $$giturl then .reference|= $$ref else . end) ' $(REPO_LIST_FILE) >>  $(REPO_LIST_FILE)  )



# make targets for creting images
git-clone:
	chmod +x clone.sh
	./clone.sh $(REPO_LIST_FILE) $(GIT_REPOS_DIR_NAME)

build-image: git-clone
	docker build  --build-arg GIT_REPO_DIR=$(GIT_REPOS_DIR_NAME) . -t $(IMAGE_REPO):$(IMAGE_TAG)

create-push-image: build-image
	docker push  $(IMAGE_REPO):$(IMAGE_TAG)

clean:
	rm -rf $(GIT_REPOS_DIR_NAME)
