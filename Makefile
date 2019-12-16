#!/usr/bin/make -f

GIT_REPOS_DIR_NAME = git_repos
REPO_LIST_FILE = repo_list
IMAGE_REPO = elifesciences/data-hub-with-dags
IMAGE_TAG = develop
UNSTABLE_IMAGE_SUFFIX =

ifdef UNSTABLE_IMAGE_SUFFIX
	IMAGE_REPO := $(IMAGE_REPO)$(UNSTABLE_IMAGE_SUFFIX)
endif

test_suffix:
	echo $(IMAGE_REPO)

git-clone:
	chmod +x clone.sh
	./clone.sh $(REPO_LIST_FILE) $(GIT_REPOS_DIR_NAME)

build-image: git-clone
	docker build  --build-arg GIT_REPO_DIR=$(GIT_REPOS_DIR_NAME) . -t $(IMAGE_REPO):$(IMAGE_TAG)

push-image: build-image
	docker push  $(IMAGE_REPO):$(IMAGE_TAG)
