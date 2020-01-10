#!/usr/bin/make -f

# variables for creating docker image
GIT_REPOS_DIR_NAME = git_repos
REPO_LIST_FILE = repo-list.json
IMAGE_REPO = elifesciences/data-hub-with-dags
IMAGE_TAG = develop


COMPOSED_MAKEFILE_ARG = DEPLOYMENT_ENV=$(DEPLOYMENT_ENV)  DEPLOYMENT_NAMESPACE=$(DEPLOYMENT_NAMESPACE) IMAGE_REPO=$(IMAGE_REPO) IMAGE_TAG=$(IMAGE_TAG)


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
