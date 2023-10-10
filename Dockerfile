FROM julia:1.9.3
WORKDIR /workdir
COPY Project.toml Project.toml
COPY docs/Project.toml docs/Project.toml
COPY src src
RUN julia --color=yes --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd()))'
COPY docs docs
