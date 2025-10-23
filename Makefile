SHELL=/bin/bash -o pipefail
REPO_USERNAME=trovediary
IMAGE_TAG=$(shell git rev-parse HEAD)
IMAGE_NAME=${REPO_USERNAME}/$*:${IMAGE_TAG}

# TOP-LEVEL RULES

build: build-docker-node-base build-docker-tex-dojo build-docker-r-base build-docker-composite
	$(MAKE) build-docker-node-dojo build-docker-r-dojo

push: push-docker-node-base build-docker-tex-dojo push-docker-r-base push-docker-composite
	$(MAKE) push-docker-node-dojo push-docker-r-dojo


# LOWER-LEVEL RULES TO BE MANUALLY INVOKED

build-docker-node-base docker-build-node-base:
build-docker-node-dojo docker-build-node-dojo:
build-docker-r-base docker-build-r-base:
build-docker-r-lambda docker-build-r-lambda:
build-docker-r-dojo docker-build-r-dojo:
build-docker-tex-dojo docker-build-tex-dojo:
push-docker-node-base docker-push-node-base:
push-docker-node-dojo docker-push-node-dojo:
push-docker-r-base docker-push-r-base:
push-docker-r-lambda docker-push-r-lambda:
push-docker-r-dojo docker-push-r-dojo:
push-docker-tex-dojo docker-push-tex-dojo:

# IMAGE-SPECIFIC RULES

test-docker-r-dojo test-docker-trove-r-dojo: docker-trove-r-dojo.image.txt
	dojo -image $(shell cat $<) docker-r-dojo/tests/test.sh

test-docker-r-% test-docker-trove-r-%: docker-trove-r-%.image.txt
	dojo -image $(shell cat $<) --docker-options "-w /dojo/work --entrypoint bash" docker-r-dojo/tests/test.sh

test-docker-node-base test-docker-trove-node-base: docker-trove-node-base.image.txt
	dojo -image $(shell cat $<) --docker-options "-w /dojo/work/docker-node-dojo" make test

test-docker-node-dojo test-docker-trove-node-dojo: docker-trove-node-dojo.image.txt
	dojo -image $(shell cat $<) "cd docker-node-dojo && make test"

test-docker-tex-dojo: docker-tex-dojo.image.txt
	dojo -image $(shell cat $<) ./docker-tex-dojo/test.sh

test-docker-composite: test-docker-composite-node test-docker-composite-r test-docker-composite-terraform
test-docker-composite-node: docker-composite.dojo.image.txt
	dojo -image $(shell cat $<) "cd docker-node-dojo && make test"
test-docker-composite-r: docker-composite.dojo.image.txt
	dojo -image $(shell cat $<) docker-r-dojo/tests/test.r
test-docker-composite-terraform: test-docker-composite-terraform-dojo test-docker-composite-circleci

test-docker-composite-terraform-dojo: docker-composite.dojo.image.txt
	rm -rf docker-composite/.terraform/
	dojo -image $(shell cat $<) "cd docker-composite && terraform init" | tee tf.dojo.log
	@$(MAKE) -s test-docker-composite-terraform-check-dojo

test-docker-composite-circleci: docker-composite.circleci.image.txt
	rm -rf docker-composite/.terraform/
	docker run --rm -i --name circleci-test trovediary/trove-composite:circleci-$(IMAGE_TAG) bash -c "cd /home/circleci/test && make test" 2>&1 | tee tf.circleci.log
	grep "Cloning into 'repo'" tf.circleci.log
	@$(MAKE) -s test-docker-composite-terraform-check-circleci

test-docker-composite-terraform-check-%: tf.%.log
	@# NB this should be run from the above rules, not directly.
	@echo "Checking $* image loads pre-installed terraform modules..."
	@export installed=$$(grep "[Ii]nstalling" $< | wc -l) && [[ "$$installed" -eq 1 ]] || \
		(echo "Error: $* image installed wrong number of terraform packages: $$installed" && exit 1)
	@export preloaded=$$(grep "Using [a-z/]* v[0-9.]* from the shared cache directory" $< | wc -l) && [[ "$$preloaded" -eq 4 ]] || \
		(echo "Error: $* image preloaded wrong number of terraform packages: $$preloaded" && exit 1)
	@echo "Success"
	@rm -f $<

# IMAGE GENERATION

pull-composite-%-if-available:
	@echo "Attempting to pull existing trove-$* image, for caching..."
	docker pull $(REPO_USERNAME)/trove-composite:$*-$(IMAGE_TAG) || true

pull-%-if-available:
	@echo "Attempting to pull existing trove-$* image, for caching..."
	docker pull $(REPO_USERNAME)/trove-$*:$(IMAGE_TAG) || true

build-docker-% docker-build-%: Dockerfile-trove-%
	@$(MAKE) --no-print-directory docker-build-trove-$*

build-docker-% docker-build-%: Dockerfile-%
	docker build -f $< -t ${IMAGE_NAME} $(shell \
		[[ "$*" == *dojo ]] && echo "--build-arg BASE_IMAGE_TAG=${IMAGE_TAG}") .
	echo ${IMAGE_NAME} >docker-$*.image.txt

build-docker-composite docker-build-composite:
	docker build -f Dockerfile-trove-r-base -t $(REPO_USERNAME)/trove-composite:r-base-$(IMAGE_TAG) . 2>&1 | tee docker-r-base.log
	docker build -f Dockerfile-trove-node-base -t $(REPO_USERNAME)/trove-composite:node-$(IMAGE_TAG) --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:r-base-$(IMAGE_TAG) .
	docker build -f Dockerfile-composite-misc -t $(REPO_USERNAME)/trove-composite:misc-$(IMAGE_TAG) --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:node-$(IMAGE_TAG) .
	docker build -f Dockerfile-trove-r-dojo -t $(REPO_USERNAME)/trove-composite:pre-dojo-$(IMAGE_TAG) --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:misc-$(IMAGE_TAG) .
	docker build -f Dockerfile-composite-final -t $(REPO_USERNAME)/trove-composite:dojo-$(IMAGE_TAG) --build-arg USERNAME=dojo --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:pre-dojo-$(IMAGE_TAG) .
	echo "$(REPO_USERNAME)/trove-composite:dojo-$(IMAGE_TAG)" >docker-composite.dojo.image.txt
	docker build -f Dockerfile-composite-circleci -t $(REPO_USERNAME)/trove-composite:pre-circleci-$(IMAGE_TAG) --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:misc-$(IMAGE_TAG) .
	docker build -f Dockerfile-composite-final -t $(REPO_USERNAME)/trove-composite:circleci-$(IMAGE_TAG) --build-arg USERNAME=circleci --build-arg BASE_IMAGE=$(REPO_USERNAME)/trove-composite:pre-circleci-$(IMAGE_TAG) .
	echo "$(REPO_USERNAME)/trove-composite:circleci-$(IMAGE_TAG)" >docker-composite.circleci.image.txt
	@echo "Images built. You may need to update your terraform lockfile: see the README for details."

terraform-update-lockfile:
	docker run --rm -v $$(pwd):/home/circleci/project \
	$$(cat docker-composite.circleci.image.txt) \
	bash -c "cd docker-composite && \
		terraform providers lock \
			-enable-plugin-cache \
			-platform=linux_amd64 -platform=darwin_arm64 -platform=linux_arm64"

enter-composite-dojo:
	dojo -image trovediary/trove-composite:dojo-$(IMAGE_TAG) bash
enter-composite-circleci:
	docker run --rm --name circleci-test -ti -v $(PWD):/home/circleci/project trovediary/trove-composite:circleci-$(IMAGE_TAG)
enter-node-dojo:
	dojo -image trovediary/trove-node-dojo:$(IMAGE_TAG) bash
enter-r-dojo:
	dojo -image trovediary/trove-r-dojo:$(IMAGE_TAG) bash

docker-composite.%.image.txt:
	echo "${REPO_USERNAME}/trove-composite:$*-${IMAGE_TAG}" >$@
docker-%.image.txt:
	echo ${IMAGE_NAME} >$@

push-docker-composite docker-push-composite: push-docker-composite-circleci push-docker-composite-dojo
	@echo "CircleCI and Dojo composite images successfully pushed."
docker-push-composite-circleci push-docker-composite-circleci: login-dockerhub build-docker-composite
	docker push $(REPO_USERNAME)/trove-composite:circleci-$(IMAGE_TAG)
docker-push-composite-dojo push-docker-composite-dojo: login-dockerhub build-docker-composite
	docker push $(REPO_USERNAME)/trove-composite:dojo-$(IMAGE_TAG)

push-docker-% docker-push-%: Dockerfile-trove-%
	@$(MAKE) --no-print-directory push-docker-trove-$*

push-docker-% docker-push-%: build-docker-% login-dockerhub
	docker push ${IMAGE_NAME}


# REPOSITORY SYMBIOSIS

dependencies-get-updates dependencies-push-update:
	./$@.sh

dependencies-get-updates-ci:
	./dependencies-get-updates.sh --ci

dependencies-push-update-ci:
	./dependencies-push-update.sh --ci


# AUTHENTICATION

login-dockerhub: need-env-DOCKERHUB_ACCESS_TOKEN
	echo "$$DOCKERHUB_ACCESS_TOKEN" | docker login -u ${REPO_USERNAME} --password-stdin

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

print-%:
	@echo "$($*)"

clean:
	git clean -xdf
