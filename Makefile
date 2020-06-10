.DEFAULT_GOAL := build

.PHONY: build
build:
	docker build -t docs-builder .
	docker run -it --rm -v $(PWD)/docs:/workdir/docs -w /workdir docs-builder julia --color=yes --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path="/workdir")); Pkg.resolve(); include("docs/make.jl")'

RELEASE_VERSION := $(or ${RELEASE_VERSION},master)
.PHONY: update
update:
	docker build -f Dockerfile.updater -t docs-updater .
	docker run -it --rm -v $(PWD):/workdir -w /workdir docs-updater bash -c "./update.sh $(RELEASE_VERSION)"
