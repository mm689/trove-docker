SHELL=/bin/bash
REPO_USERNAME=trovediary
IMAGE_TAG=$(shell git rev-parse HEAD)
IMAGE_NAME=${REPO_USERNAME}/$*:${IMAGE_TAG}

# TOP-LEVEL RULES

build: build-docker-trove-node-dojo build-docker-tex-dojo build-docker-trove-r-base
	$(MAKE) build-docker-trove-r-dojo

push: push-docker-node-dojo build-docker-tex-dojo push-docker-r-base
	$(MAKE) push-docker-trove-r-dojo


# LOWER-LEVEL RULES TO BE MANUALLY INVOKED

build-docker-node-dojo docker-build-node-dojo:
build-docker-r-base docker-build-r-base:
build-docker-r-dojo docker-build-r-dojo:
build-docker-tex-dojo docker-build-tex-dojo:
push-docker-node-dojo docker-push-node-dojo:
push-docker-r-base docker-push-r-base:
push-docker-r-dojo docker-push-r-dojo:
push-docker-tex-dojo docker-push-tex-dojo:


# IMAGE-SPECIFIC RULES

test-docker-r-base test-docker-trove-r-base: docker-trove-r-base.image.txt
	dojo -image $$(cat $<) docker-r-dojo/tests/test.r

test-docker-r-dojo test-docker-trove-r-dojo: docker-trove-r-dojo.image.txt
	dojo -image $$(cat $<) docker-r-dojo/tests/test.r

test-docker-node-dojo test-docker-trove-node-dojo: docker-trove-node-dojo.image.txt
	dojo -image $$(cat $<) "cd docker-node-dojo && make test"

test-docker-tex-dojo: docker-tex-dojo.image.txt
	dojo -image $$(cat $<) ./docker-tex-dojo/test.sh


# IMAGE GENERATION

build-docker-% docker-build-%: Dockerfile-trove-%
	@$(MAKE) --no-print-directory docker-build-trove-$*

build-docker-% docker-build-%: Dockerfile-%
	docker build -f $< -t ${IMAGE_NAME} $(shell \
		[ "$*" == "trove-r-dojo" ] && echo "--build-arg FROM_IMAGE_TAG=${IMAGE_TAG}") .

docker-%.image.txt:
	echo ${IMAGE_NAME} >$@

push-docker-% docker-push-%: Dockerfile-trove-%
	@$(MAKE) --no-print-directory push-docker-trove-$*

push-docker-% docker-push-%: build-docker-% login-dockerhub
	docker push ${IMAGE_NAME}


# REPOSITORY SYMBIOSIS

dependencies-get-updates dependencies-push-update:
	./$@.sh

gocd-dependencies-get-updates:
	@$(MAKE) --no-print-directory dependencies-get-updates
	git push origin master

gocd-dependencies-push-update:
	@$(MAKE) --no-print-directory dependencies-push-update
	cd diary && git push origin master


# AUTHENTICATION

login-dockerhub: need-env-DOCKERHUB_ACCESS_TOKEN
	docker login -u ${REPO_USERNAME} -p "$$DOCKERHUB_ACCESS_TOKEN"

# Obsolete rules for storing images in AWS ECR.
need-aws-credentials: need-env-AWS_ACCESS_KEY_ID need-env-AWS_SECRET_ACCESS_KEY
run-login-aws:
	@# Login to AWS registry to be able to push. Do via dojo AWS image, so no need for installing AWS CLI.
	eval $$(dojo -c Dojofile-aws "aws ecr get-login --region eu-west-1 --no-include-email || echo 'exit 1'")
login-aws: need-aws-credentials
	$(MAKE) --no-print-directory run-login-aws


# UTILITY RULES

need-env-%:
	@if [ -z "$($*)" ]; then \
		echo "Missing environment variable: $*" >&2; \
		exit 1; \
	fi

clean:
	git clean -xdf
