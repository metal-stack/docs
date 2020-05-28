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
        "Overview" => "index.md",
        "Architecture" => Any[
            "Components" => "architecture/the_stack.md",
            "Networking" => "architecture/networking.md",
        ],
        "Getting Started" => Any[
            "Guides" => "guides.md",
            "mini-lab" => "external/mini-lab/README.md",
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
