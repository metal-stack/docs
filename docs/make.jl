using Documenter

is_ci_build = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename="metal-stack",
    format = Documenter.HTML(
        prettyurls = is_ci_build,
        assets = ["assets/favicon.ico"],
        canonical = "https://metal-stack.github.io/docs/master/",
        highlights = ["yaml"],
    ),
    authors = "metal-stack authors and contributors.",
    pages = [
        "Introduction" => "index.md",
        "Overview" => Any[
            "Architecture" => "overview/architecture.md",
            "Networking" => "overview/networking.md",
            "Operating Systems" => "overview/os.md",
            "Hardware Support" => "overview/hardware.md",
            "Kubernetes Integration" => "overview/kubernetes.md",
        ],
        "Quickstart" => "quickstart.md",
        "User Guides" => Any[
            "mini-lab" => "external/mini-lab/README.md",
            "metalctl" => "external/metalctl/README.md",
        ],
        "Installation & Maintenance" => Any[
            "Installation" => "installation/deployment.md",
            "Monitoring" => "installation/monitoring.md",
            "Troubleshoot" => "installation/troubleshoot.md",
        ],
        "API Documentation" => "api_docs.md",
        "Development" => "development.md",
        "contributing.md",
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
        push_preview = true,
    )
end
