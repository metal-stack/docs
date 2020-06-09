.DEFAULT_GOAL := build

.PHONY: build
build:
	docker build -t docs-builder .
	docker run -it --rm -v $(PWD)/docs:/workdir/docs -w /workdir docs-builder julia --color=yes --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path="/workdir")); Pkg.resolve(); include("docs/make.jl")'
