# Docs

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.metal-stack.io/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://docs.metal-stack.io/dev/)

This repository contains the documentation of metal-stack at [docs.metal-stack.io](https://docs.metal-stack.io/).

It is being generated using [Julia Documenter](https://github.com/JuliaDocs/Documenter.jl). Everything is basically build on Markdown files. Check their [docs](https://juliadocs.github.io/Documenter.jl/stable/) if you want to dig deeper.

## Development

To generate the documentation you can use the following command (only Docker is required):

```
make
```

The result is being written to `docs/build` and is fully static. You can simply view it in your browser by opening `docs/build/index.html`.

To update the docs that is included from external repositories (e.g. metalctl, mini-lab, ...), you can run the following target:

```
RELEASE_VERSION=master make update
```

The `RELEASE_VERSION` points to our [releases](https://github.com/metal-stack/releases) repository.

## Pull Requests

A pull request will automatically generate a preview on our Gitlab page with Github Actions on `https://docs.metal-stack.io/previews/PR<your-pr-number>`.
