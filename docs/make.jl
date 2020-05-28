import Pkg
Pkg.add("Documenter")

push!(LOAD_PATH,"../src/")

using Documenter, Example

is_ci_build = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename="metal-stack",
    format = Documenter.HTML(
        prettyurls = is_ci_build
    ),
    authors = "metal-stack authors and contributors.",
    pages = [
        "index.md",
        "getting_started.md",
        "Architecture" => Any[
            "The Stack" => "architecture/the_stack.md",
            "Networking" => "architecture/networking.md",
        ],
        "enhancement_proposals.md",
        "contributing.md",
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
    )
end
