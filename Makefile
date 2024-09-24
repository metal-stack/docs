.DEFAULT_GOAL := build
RELEASE_VERSION := $(or ${RELEASE_VERSION},"v0.18.14")

ifeq ($(CI),true)
DOCKER_TTY_ARG=
else
DOCKER_TTY_ARG=t
endif

.PHONY: build
build:
	docker build -t docs-builder .
	docker run -i$(DOCKER_TTY_ARG) --rm \
	  -v $(PWD):/workdir \
	  -v $(PWD)/.gitconfig:/root/.gitconfig \
	  -e RELEASE_VERSION=$(RELEASE_VERSION) \
	  -w /workdir \
	  docs-builder julia \
	    --color=yes \
		--project=docs/ \
		-e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.resolve(); include("docs/make.jl")'

.PHONY: update
update:
	docker build -f Dockerfile.updater -t docs-updater .
	docker run -i$(DOCKER_TTY_ARG) --rm \
	  -u $$(id -u):$$(id -g) \
	  -v $(PWD):/workdir \
	  -w /workdir \
	  docs-updater bash \
	    -c "./update.sh $(RELEASE_VERSION)"
