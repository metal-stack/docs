# Docs

[![Stable Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.metal-stack.io/)
[![Devel Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://docs.metal-stack.io/dev/)

This repository contains the documentation of metal-stack at [docs.metal-stack.io](https://docs.metal-stack.io/).

It is being generated using [Julia Documenter](https://github.com/JuliaDocs/Documenter.jl). Everything is basically build on Markdown files. Check their [docs](https://juliadocs.github.io/Documenter.jl/stable/) if you want to dig deeper.

## Development

To generate the documentation you can use the following command (only Docker is required):

```bash
make
```

The result is being written to `docs/build` and is fully static. You can simply view it in your browser by opening `docs/build/index.html`.

To update the docs that is included from external repositories (e.g. metalctl, mini-lab, ...), you can run the following target:

```make
RELEASE_VERSION=master make update
```

The `RELEASE_VERSION` points to our [releases](https://github.com/metal-stack/releases) repository.

## Pull Requests

A pull request will automatically generate a preview on our Gitlab page with Github Actions on `https://docs.metal-stack.io/previews/PR<your-pr-number>`.

## How to organize the docs?

- Prioritize the `concept` section. If this is about a MEP, you likely already have the contents for this.
- Use the `general` section to distribute users to their sections or to the deeper concept.
- user, operator or developer specific sections would be nice, but are optional.

### Example

- Roles and Permissions
  - Concept: explains all roles, permissions and sessions
  - For operators: OIDC, creation in CI, ... How to / Explanation
  - For users: how to guide to create tokens and edit permissions
  - General: base concept, links to How to guides and deeper Concept
  - CISO / Compliance: minimal need to know Principle Explanation / Concept
