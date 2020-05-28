.DEFAULT_GOAL := build

.PHONY: build
build:
	docker run -it --rm -v $(PWD):/workdir -w /workdir julia:1.4.2 julia docs/make.jl
