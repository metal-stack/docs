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
        "Introduction" => "index.md",
        "Overview" => Any[
            "Architecture" => "overview/architecture.md",
            "Networking" => "overview/networking.md",
            "Operating Systems" => "overview/os.md",
            "Hardware Support" => "overview/hardware.md",
        ],
        "Guides" => Any[
            "Getting Started" => "getting_started.md",
            "mini-lab" => "external/mini-lab/README.md",
            "metalctl" => "external/metalctl/README.md",
        ],
        "Getting Serious" => Any[
            "Buying Hardware" => "installation/hardware.md",
            "Installation" => "installation/deployment.md",
            "Monitoring" => "installation/monitoring.md",
            "Troubleshooting" => "installation/troubleshooting.md",
        ],
        "Enhancement Proposals" => "proposals/index.md",
        "Support" => "support.md",
        "contributing.md",
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
        push_preview = true,
    )
end
