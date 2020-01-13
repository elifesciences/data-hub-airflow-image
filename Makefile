#!/usr/bin/make -f

# variables for creating docker image
GIT_REPOS_DIR_NAME = git_repos
REPO_LIST_FILE = unstable-image-repo-list.json
IMAGE_REPO = elifesciences/data-hub-with-dags
IMAGE_TAG = develop

BRANCH_TO_UPDATE =
GIT_URL_TO_UPDATE =
NEW_GIT_URL_REF =


COMPOSED_MAKEFILE_ARG = DEPLOYMENT_ENV=$(DEPLOYMENT_ENV)  DEPLOYMENT_NAMESPACE=$(DEPLOYMENT_NAMESPACE) IMAGE_REPO=$(IMAGE_REPO) IMAGE_TAG=$(IMAGE_TAG)


# update repo list file with new ref
update-repo-list:
	echo $$( FILECONTENT=$$(cat $(REPO_LIST_FILE) | jq  --arg giturl $(GIT_URL_TO_UPDATE)  --arg ref  $(NEW_GIT_URL_REF) -c '. | map( if .git_repo_url == $$giturl then .reference|= $$ref else . end) ') && echo $${FILECONTENT} > $(REPO_LIST_FILE)  )

git-repo-list-update-commit: update-repo-list
	git commit -m "Updated Ref of $(GIT_URL_TO_UPDATE) to $(NEW_GIT_URL_REF)" $(REPO_LIST_FILE)

git-push-updated-repo-list: git-repo-list-update-commit
	git push origin $(BRANCH_TO_UPDATE)


# make targets for creating images
git-clone:
	chmod +x clone.sh
	./clone.sh $(REPO_LIST_FILE) $(GIT_REPOS_DIR_NAME)

build-image: git-clone
	docker build  --build-arg GIT_REPO_DIR=$(GIT_REPOS_DIR_NAME) . -t $(IMAGE_REPO):$(IMAGE_TAG)

create-push-image: build-image
	docker push  $(IMAGE_REPO):$(IMAGE_TAG)

clean:
	rm -rf $(GIT_REPOS_DIR_NAME)
