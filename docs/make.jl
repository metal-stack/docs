using Documenter

is_ci_build = get(ENV, "CI", nothing) == "true"

makedocs(
    repo = "github.com/metal-stack/docs.git",
    sitename="metal-stack",
    format = Documenter.HTML(
        repolink = "https://github.com/metal-stack/docs.git",
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
    warnonly = true, # TODO: Should be disabled soon, links from repos to CONTRIBUTING have to be updated though...
    clean = true,
    pages = [
        "Home" => "index.md",
        "Concepts" => [
            "Why metal-stack" => "concepts/why-metal-stack.md",
            "Bare Metal" => "concepts/bare-metal.md",
            "Architecture" => "concepts/architecture.md",
            "Networking" => [
                "Theory" => "concepts/network/theory.md",
                "Firewalls" => "concepts/network/firewalls.md",
            ]
            "Hardware Support" => "concepts/hardware.md",
            "Operating Systems" => "concepts/os.md",
            "Kubernetes" => [
                "Cloud Controller Manager" => "concepts/cloud-controller-manager.md",
                "Firewall Controller Manager" => "concepts/firewall-controller-manager.md",
                "Gardener" => "concepts/gardener.md",
                "Cluster API" => "concepts/cluster-api.md",
                "Isolated Cluster" => "concepts/isolated-clusters.md",
                "GPU Workers" => "concepts/gpu-support.md",
            ],
            "Storage" => "concepts/storage.md",
            "Comparison" => "concepts/comparison.md",
        ],
        "For Operators" => [
            "Supported Hardware" => "operators/hardware.md",
            "Operating Systems" => "operators/os.md"
            "Deployment Concepts" => "operators/deployment-concepts.md"
            "Deployment Guide" => "operators/deployment-guide.md"
            "Upgrades" => "operators/upgrades.md"
            "Troubleshoot" => "operators/troubleshoot.md"
        ],
        "For Users" => [
            "Manual" => "users/manual.md",
            "Client Libraries" => "users/client-libraries.md"
            "Ansible Integration" => "users/integration-ansible.md"
        ],
        "Installation & Administration" => [
            "Installation" => "installation/deployment.md",
            "Releases and Updates" => "installation/updates.md",
            "Monitoring" => "installation/monitoring.md",
            "Troubleshoot" => "installation/troubleshoot.md",
        ],
        "User Guides" => [
            "mini-lab" => "external/mini-lab/README.md",
            "metalctl" => "external/metalctl/README.md",
            "csi-driver-lvm" => "external/csi-driver-lvm/README.md",
            "firewall-controller" => "external/firewall-controller/README.md",
            "tailscale" => "external/tailscale/README.md",
        ],
        "API Documentation" => "apidocs/apidocs.md",
        "Development" => [
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
