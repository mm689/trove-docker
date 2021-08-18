# Trove Diary Docker Images

Docker images created for the [Trove](https://diary.martinmccaffery.com/) diary-writing project

These images are intended to speed up and render more consistent the deployment of short programming tasks - such as running integration tests, or CI/CD steps - in different languages. They come pre-installed with:
- relevant language-specific packages where appropriate, and
- [Dojo](https://github.com/kudulab/dojo), a system for cleanly running ephemeral [Docker](https://docs.docker.com/install/) containers

## Images

The images provided by this repository can be found on [DockerHub](https://hub.docker.com/):
- [trove-r-base](https://hub.docker.com/repository/docker/trovediary/trove-r-base/), an [R](https://www.r-project.org/) image with all [packages](package-list.r) required for Trove installed
- [trove-r-dojo](https://hub.docker.com/repository/docker/trovediary/trove-r-dojo/), simply [r-base](node-dojo) with [Dojo](https://github.com/kudulab/dojo) installed on top
- [trove-node-dojo](https://hub.docker.com/repository/docker/trovediary/trove-node-dojo/), a [node.js](https://nodejs.org/)-capable image with [Dojo](https://github.com/kudulab/dojo)
- [tex-dojo](https://hub.docker.com/repository/docker/trovediary/tex-dojo/), a [LaTeX](https://www.latex-project.org/) image based on [blang/latex](https://github.com/blang/latex-docker) with [Dojo](https://github.com/kudulab/dojo) installed on top

- [trove-composite](https://hub.docker.com/repository/docker/trovediary/trove-composite/), a _pair_ of combined images, tagged as `circleci-<hash>` or `dojo-<hash>`, with most of the above installed in the following order:
  1. _[circleci-,dojo-]_ `R` as per [trove-r-dojo](Dockerfile-r-base)
  1. _[circleci-,dojo-]_ `node.js` as per [trove-node-base](Dockerfile-node-base)
  1. _[circleci-,dojo-]_ `ansible`, `terraform` and `aws` as per [composite-misc](Dockerfile-composite-misc)
  1. _[circleci-,~dojo-~]_ Various [CircleCI-recommended](https://github.com/CircleCI-Public/cimg-base/blob/master/20.04/Dockerfile) tools as per [composite-circleci](Dockerfile-composite-circleci)
  1. `dojo`
    - _[circleci-,~dojo-~]_ Simply a [fake binary](docker-composite/fake_dojo.sh) which ignores the command
    - _[~circleci-~,dojo-]_ Standard `dojo` as per [r-dojo](Dockerfile-r-dojo)
  1. _[circleci-,dojo-]_ `terraform` modules as per [composite-final](Dockerfile-composite-final), installed on both the above images

## Usage
This repository is for generating images. Full details on the process of generating, testing and deploying them can be found in the [CircleCI](https://app.circleci.com/pipelines/github/mm689/trove-docker) [workflow spec](.circleci/config.yml) or [GoCD](https://www.gocd.org/) [pipeline spec](trove-docker.gocd.yml)). The main elements of these are:

To build local images:
- `make build` or `make build-docker-<image name>`

To verify locally built images:
- `make test-docker-<image name>`

To retrieve updates to the list of R packages to pre-install:
- `make dependencies-get-updates`

To commit updated package lists and docker image tags to the main [Trove](https://github.com/mm689/trove) repository:
- `make dependencies-push-updates`
