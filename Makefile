.DEFAULT_GOAL := build
RELEASE_VERSION := $(or ${RELEASE_VERSION},"v0.1.5")

.PHONY: build
build:
	docker build -t docs-builder .
	docker run -it --rm \
	  -v $(PWD)/docs:/workdir/docs \
	  -e RELEASE_VERSION=$(RELEASE_VERSION) \
	  -w /workdir \
	  docs-builder julia \
	    --color=yes \
		--project=docs/ \
		-e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.resolve(); include("docs/make.jl")'

.PHONY: update
update:
	docker build -f Dockerfile.updater -t docs-updater .
	docker run -it --rm \
	  -u $$(id -u):$$(id -g) \
	  -v $(PWD):/workdir \
	  -w /workdir \
	  docs-updater bash \
	    -c "./update.sh $(RELEASE_VERSION)"
