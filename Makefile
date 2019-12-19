#!/usr/bin/make -f

# variables for creating docker image
GIT_REPOS_DIR_NAME = git_repos
REPO_LIST_FILE = repo-list.json
IMAGE_REPO = elifesciences/data-hub-with-dags
IMAGE_TAG = develop
UNSTABLE_IMAGE_SUFFIX =

ifdef UNSTABLE_IMAGE_SUFFIX
	IMAGE_REPO := $(IMAGE_REPO)$(UNSTABLE_IMAGE_SUFFIX)
endif

# variables used for deploying newly created image into k8s
FORMULA_REPO_DIR = data-hub-formula-repo
FORMULA_GIT_REPO = git@github.com:elifesciences/elife-data-hub-formula.git
FORMULA_GIT_REPO_REF = origin/master

DEPLOYMENT_ENV = staging
DEPLOYMENT_NAMESPACE = data-hub
CHART_GIT_REPO = git@github.com:elifesciences/elife-data-hub-charts.git

CREATED_AWS_K8S_SECRET =
CREATED_G_APPLICATION_CRED_K8S_SECRET =
CREATED_GOOGLE_OAUTH_SECRET =

COMPOSED_MAKEFILE_ARG = DEPLOYMENT_ENV=$(DEPLOYMENT_ENV)  DEPLOYMENT_NAMESPACE=$(DEPLOYMENT_NAMESPACE) IMAGE_REPO=$(IMAGE_REPO) IMAGE_TAG=$(IMAGE_TAG)

ifdef CREATED_AWS_K8S_SECRET
	COMPOSED_MAKEFILE_ARG := $(COMPOSED_MAKEFILE_ARG)  CREATED_AWS_K8S_SECRET=$(CREATED_AWS_K8S_SECRET)
endif

ifdef CREATED_G_APPLICATION_CRED_K8S_SECRET
	COMPOSED_MAKEFILE_ARG := $(COMPOSED_MAKEFILE_ARG)  CREATED_G_APPLICATION_CRED_K8S_SECRET=$(CREATED_G_APPLICATION_CRED_K8S_SECRET)
endif

ifdef CREATED_GOOGLE_OAUTH_SECRET
	COMPOSED_MAKEFILE_ARG := $(COMPOSED_MAKEFILE_ARG)  CREATED_GOOGLE_OAUTH_SECRET=$(CREATED_GOOGLE_OAUTH_SECRET)
endif

# make targets for creting images
git-clone:
	chmod +x clone.sh
	./clone.sh $(REPO_LIST_FILE) $(GIT_REPOS_DIR_NAME)

build-image: git-clone
	docker build  --build-arg GIT_REPO_DIR=$(GIT_REPOS_DIR_NAME) . -t $(IMAGE_REPO):$(IMAGE_TAG)

create-push-image: build-image
	docker push  $(IMAGE_REPO):$(IMAGE_TAG)


# make targets for deploying image into k8s
clone-formula-repo:
	git clone $(FORMULA_GIT_REPO)  $(FORMULA_REPO_DIR)

clone-reset-formula-repo-to-ref: clone-formula-repo
	git -C $(FORMULA_REPO_DIR) reset --hard $(FORMULA_GIT_REPO_REF)

deploy-image-to-k8s: create-push-image clone-reset-formula-repo-to-ref
	make -C $(FORMULA_REPO_DIR)  $(COMPOSED_MAKEFILE_ARG) deploy-chart
	make clean

clean:
	rm -rf $(FORMULA_REPO_DIR)
	rm -rf $(GIT_REPOS_DIR_NAME)
