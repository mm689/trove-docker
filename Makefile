
# TOP-LEVEL RULES

build: build-docker-node-dojo build-docker-r-base
	$(MAKE) build-docker-r-dojo

push: push-docker-node-dojo push-docker-r-base
		$(MAKE) push-docker-r-dojo


# STAGE/IMAGE-SPECIFIC RULES

test-docker-r-base: docker-r-base.image.txt
	dojo -image $$(cat $<) docker-r-dojo/tests/test.r

test-docker-r-dojo: docker-r-dojo.image.txt
	dojo -image $$(cat $<) docker-r-dojo/tests/test.r

test-docker-node-dojo: docker-node-dojo.image.txt
	dojo -image $$(cat $<) "cd docker-node-dojo && make test"


# UTILITY RULES

build-docker-node-dojo docker-build-node-dojo: docker-build-node-dojo
build-docker-r-base docker-build-r-base: docker-build-r-base
build-docker-r-dojo docker-build-r-dojo: docker-build-r-dojo
push-docker-node-dojo docker-push-node-dojo: push-docker-node-dojo
push-docker-r-base docker-push-r-base: push-docker-r-base
push-docker-r-dojo docker-push-r-dojo: push-docker-r-dojo

docker-build-% build-docker-% docker-%.image.txt: Dockerfile-%
	IMAGE_NAME="907983613156.dkr.ecr.eu-west-1.amazonaws.com/diary-$*:$(shell git rev-parse HEAD)" &&\
	docker build -f Dockerfile-$* -t $$IMAGE_NAME --build-arg TAG=$(shell git rev-parse HEAD) . &&\
	echo "$$IMAGE_NAME" >docker-$*.image.txt

# Copy package rules from diary/, assuming that's in a sibling directory.
package-list.js: ../diary/package-list.js
	cp -p $< .
package-list.r: ../diary/package-list.r
	cat $< | grep -Ev '^(#|$$)' >$@

push-docker-%: docker-%.image.txt login-aws
	$(MAKE) build-docker-$*
	docker push $$(cat $<)

need-env-%:
	@if [ -z "$($*)" ]; then \
		echo "Missing environment variable: $*" >&2; \
		exit 1; \
	fi

# Check for any updates to package lists.
dependencies-get-updates:
	rm -rf diary
	git clone git@github.com:mm689/diary.git
	cd diary && make package-list.js
	cp -p diary/package-list.* .
	rm -f package-list.extra.r
	sed -E -i '' '/^(#|$$)/d' package-list.r
	git reset
	git add package-list.*
	@if [ -z "$$(git diff --cached)" ]; then echo "No changes to package lists detected" >&2 && exit 1; fi
	@# Generate and apply a pretty commit message.
	@git commit -m "[Automatic] Updated \
	$$(git diff --cached --name-only | sed -E 's/.*[.]([^.]+)$$/\1/' | tr [a-z] [A-Z] \
	| sort | uniq | tr '\n' ',' | sed 's/,$$//;s/,/ and /') \
	package list$$(git diff --cached --name-only | tail -n +2 | grep . >/dev/null && echo 's')"
gocd-dependencies-get-updates:
	@$(MAKE) --no-print-directory dependencies-get-updates
	git push origin master

# Store in the dependent repository an upgraded commit's tag.
dependencies-push-update:
	rm -rf diary
	git clone git@github.com:mm689/diary.git
	sed -i '' -E "s/(diary-(node-dojo|r-base|r-dojo)):([a-f0-9]{40})/\1:$(shell git rev-parse HEAD)/g" diary/dkr/*
	cd diary && git commit -m "[Automatic] Upgrading versions of docker images"
gocd-dependencies-push-update:
	@$(MAKE) --no-print-directory dependencies-push-update
	cd diary && git push origin master

need-aws-credentials: need-env-AWS_ACCESS_KEY_ID need-env-AWS_SECRET_ACCESS_KEY

run-login-aws:
	@# Login to AWS registry to be able to push. Do via dojo AWS image, so no need for installing AWS CLI.
	eval $$(dojo -c Dojofile-aws "aws ecr get-login --region eu-west-1 --no-include-email || echo 'exit 1'")

login-aws: need-aws-credentials
	$(MAKE) --no-print-directory run-login-aws


# MANUAL UTILITY RULES

clean:
	rm -rf *.image.txt */node_modules
