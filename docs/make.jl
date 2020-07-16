using Documenter

is_ci_build = get(ENV, "CI", nothing) == "true"

makedocs(
    sitename="metal-stack",
    format = Documenter.HTML(
        prettyurls = is_ci_build,
        assets = ["assets/favicon.ico", "assets/youtube.css"],
        canonical = "https://docs.metal-stack.io/",
        highlights = ["yaml"],
    ),
    authors = "metal-stack authors and contributors.",
    linkcheck = is_ci_build,
    linkcheck_ignore = [
        r"^(?!http)",
    ],
    #strict = true, # TODO: Should be enabled soon, links from repos to CONTRIBUTING have to be updated though...
    clean = true,
    pages = [
        "Introduction" => "index.md",
        "Overview" => Any[
            "Architecture" => "overview/architecture.md",
            "Networking" => "overview/networking.md",
            "Hardware Support" => "overview/hardware.md",
            "Operating Systems" => "overview/os.md",
            "Kubernetes Integration" => "overview/kubernetes.md",
        ],
        "Quickstart" => "quickstart.md",
        "Installation & Maintenance" => Any[
            "Installation" => "installation/deployment.md",
            "Monitoring" => "installation/monitoring.md",
            "Troubleshoot" => "installation/troubleshoot.md",
        ],
        "User Guides" => Any[
            "mini-lab" => "external/mini-lab/README.md",
            "metalctl" => "external/metalctl/README.md",
            "csi-lvm" => "external/csi-lvm/README.md",
            "firewall-controller" => "external/firewall-controller/README.md",
        ],
        "API Documentation" => "apidocs/apidocs.md",
        "Development" => Any[
            "development/client_libraries.md",
            "development/roadmap.md",
            "Enhancement Proposals" => "development/proposals/index.md",
            "development/contributing.md",
        ],
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
        push_preview = true,
    )
end
