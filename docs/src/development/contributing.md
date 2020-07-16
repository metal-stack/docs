# Contributing

This document describes the way we want to contribute code to the projects of metal-stack, which are hosted on [github.com/metal-stack](https://github.com/metal-stack).

The document is meant to be understood as a general guideline for contributions, but not as burden to be placed on a developer. Use your best judgment when contributing code. Try to be as clean and precise as possible when writing code and try to make your code as maintainable and understandable as possible for other people.

Even if it should go without saying, we live an open culture of discussion, in which everybody is welcome to participate. We treat every contribution with respect and objectiveness with the general aim to write software of quality.

If you want, feel free to propose changes to this document in a pull request.

```@contents
Pages = ["contributing.md"]
Depth = 5
```

## How Can I Contribute?

Open a Github issue in the project you would like to contribute. Within the issue, your idea can be discussed. It is also possible to directly create a pull request when the set of changes is relatively small.

### Pull Requests

The process described here has several goals:

- Maintain quality
- Enable a sustainable system to review contributions
- Enable documented and reproducible addition of contributions

1. Create a meaningful issue describing the WHY? of your contribution
1. Create a repository fork within the context of that issue.
1. Create a Draft Pull Request to the master branch of the target repository.
1. Develop, document and test your contribution (try not to solve more than one issue in a single pull request)
1. Ask for merging your contribution by removing the draft marker
1. If code owners are defined, try to assign the request to a code owner

## General Objectives

This section contains language-agnostic topics that all metal-stack projects are trying to follow.

### Code Ownership

The code base is owned by the entire team and every member is allowed to contribute changes to any of the projects. This is considered as collective code ownership[^1].

As a matter of fact, there are persons in a project, which already have experience with the sources. These are defined directly in the repository's [CODEOWNERS](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners) file. If you want to merge changes into the master branch, it is advisable to include code owners into the proecess of discussion and merging.

### Microservices

One major ambition of metal-stack is to follow the idea of [microservices](https://en.wikipedia.org/wiki/Microservices). This way, we want to achieve that we can

- adapt to changes faster than with monolithic architectures,
- be free of restrictions due to certain choices of technology,
- leverage powerful traits of cloud infrastructures (e.g. high-scalability, high-availability, ...).

### Programming Languages

We are generally open to write code in any language that fits best to the function of the software. However, we encourage [golang](https://en.wikipedia.org/wiki/Go_(programming_language)) to be the main language of metal-stack as we think that it makes development faster when not establishing too many different languages in our architecture. Reason for this is that we are striving for consistent behavior of the microservices, similar to what has been described for the Twelve-Factor App (see https://12factor.net/). We help enforcing unified behavior by allowing a small layer of shared code for every programming language. We will refer to this shared code as "libraries" for the rest of this document.

### Artifacts

Artifacts are always produced by a CI process (Github Actions).

Docker images are published on Docker Hub using the [metalstack](https://hub.docker.com/u/metalstack) user.

Binary artifacts or images are uploaded to GKE buckets.

When building Docker images, please consider our build tool [docker-make](https://github.com/fi-ts/docker-make) or the specific [docker-make action](https://github.com/metal-stack/action-docker-make) respectively.

### APIs

We are currently making use of [Swagger](https://swagger.io/) when we exposing traditional REST APIs for end-users. This helps us with being technology-agnostic as we can generate clients in almost any language using [go-swagger](https://goswagger.io/). Swagger additionally simplifies the documentation of our APIs.

Most APIs though are not required to be user-facing but are of technical nature. These are preferred to be implemented using [grpc](https://grpc.io/).

#### Versioning

Artifacts are versioned by tagging the respective repository with a tag starting with the letter `v`. After the letter, there stands a valid [semantic version](https://semver.org/).

### Documentation

In order to make it easier for others to understand a project, we document general information and usage instructions in a `README.md` in any project.

In addition to that, we document a microservice in the [docs](https://github.com/metal-stack/docs) repository. The documentation should contain the reasoning why this service exists and why it was being implemented the way it was being implemented. The aim of this procedure is to reduce the time for contributors to comprehend architectural decisions that were made during the process of writing the software and to clarify the general purpose of this service in the entire context of the software.

## Guidelines

This chapter describes general guidelines on how to develop and contribute code for a certain programming language.

### Golang

Development follows the official guide to:

- Write clear, idiomatic Go code[^2]
- Learn from mistakes that must not be repeated[^3]
- Apply appropriate names to your artifacts:
  - [https://talks.golang.org/2014/names.slide#1](https://talks.golang.org/2014/names.slide#1)
  - [https://blog.golang.org/package-names](https://blog.golang.org/package-names)
  - [https://golang.org/doc/effective_go.html#names](https://golang.org/doc/effective_go.html#names)
- Enable others to understand the reasoning of non-trivial code sequences by applying a meaningful documentation.

#### Development Decisions

- **Dependency Management** by using Go modules
- **Build and Test Automation** by using [GNU Make](https://linux.die.net/man/1/make).
- **End-user APIs** should consider using go-swagger and [Go-Restful](https://github.com/emicklei/go-restful)
  **Technical APIs** should consider using [grpc](https://grpc.io/)

#### Libraries

metal-stack maintains several libraries that you should utilize in your project in order unify common behavior. Some of these projects are:

- [metal-go](https://github.com/metal-stack/metal-go)
- [metal-lib](https://github.com/metal-stack/metal-lib)

#### Error Handling with Generated Swagger Clients

From the server-side you should ensure that you are returning the common error json struct in case of an error as defined in the `metal-lib/httperrors`. Ensure you are using `go-restful >= v2.9.1` and `go-restful-openapi >= v0.13.1` (allows default responses with error codes other than 200).

### Documentation

We want to share knowledge and keep things simple. If things cannot kept simple we want enable everybody to understand them by:

- Document in short sentences[^4].
- Do not explain the HOW (this is already documented by your code and documenting the obvious is considered a defect).
- Explain the WHY. Add a "to" in your documentation line to force yourself to explain the reasonning (e.g.  "`<THE WHAT> to <THE TO>`").

### Python

Development follows the official guide to:

- Style Guide for Python Code (PEP 8)[^5]
  - The use of an IDE like [PyCharm](https://www.jetbrains.com/pycharm/) helps to write compliant code easily
- Consider [setuptools](https://pythonhosted.org/an_example_pypi_project/setuptools.html) for packaging
- If you want to add a Python microservice to the mix, consider [pyinstaller](https://www.pyinstaller.org/) on Alpine to achieve small image sizes

[^1]: [https://martinfowler.com/bliki/CodeOwnership.html](https://martinfowler.com/bliki/CodeOwnership.html)
[^2]: [https://golang.org/doc/effective_go.html](https://golang.org/doc/effective_go.html)
[^3]: [https://github.com/golang/go/wiki/CodeReviewComments](https://github.com/golang/go/wiki/CodeReviewComments)
[^4]: [https://github.com/golang/go/wiki/CodeReviewComments#comment-sentences](https://github.com/golang/go/wiki/CodeReviewComments#comment-sentences)
[^5]: [https://www.python.org/dev/peps/pep-0008/](https://www.python.org/dev/peps/pep-0008/)
