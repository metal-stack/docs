import Pkg
Pkg.add("Documenter")

push!(LOAD_PATH,"src/")

using Documenter

is_ci_build = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename="metal-stack",
    format = Documenter.HTML(
        prettyurls = is_ci_build,
        assets = ["assets/favicon.ico"],
    ),
    authors = "metal-stack authors and contributors.",
    pages = [
        "index.md",
        "getting_started.md",
        "Architecture" => Any[
            "The Stack" => "architecture/the_stack.md",
            "Networking" => "architecture/networking.md",
        ],
        "Enhancement Proposals" => "proposals/index.md",
        "contributing.md",
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
        push_preview = true,
    )
end
