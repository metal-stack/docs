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
        "Getting Started" => "getting-started.md",
        "Concepts" => [
            "Why metal-stack" => "concepts/why-metal-stack.md",
            "Why Bare Metal" => "concepts/why-bare-metal.md",
            "Architecture" => "concepts/architecture.md",
            "Network" => [
                "Theory" => "concepts/network/theory.md",
                "Firewalls" => "concepts/network/firewalls.md"
            ],
            "Kubernetes" => [
                "Cloud Controller Manager" => "concepts/kubernetes/cloud-controller-manager.md",
                "Firewall Controller Manager" => "concepts/kubernetes/firewall-controller-manager.md",
                "Gardener" => "concepts/kubernetes/gardener.md",
                "Isolated Cluster" => "concepts/kubernetes/isolated-clusters.md",
                "GPU Workers" => "concepts/kubernetes/gpu-workers.md",
                "Storage" => "concepts/kubernetes/storage.md"
            ]
        ],
        "For Operators" => [
            "Supported Hardware" => "operators/hardware.md",
            "Operating Systems" => "operators/operating-systems.md",
            "Deployment Guide" => "operators/deployment-guide.md",
            "Upgrades" => "operators/upgrades.md",
            "Troubleshoot" => "operators/troubleshoot.md"
        ],
        "For Users" => [
            "Client Libraries" => "users/client-libraries.md",
        ],
        "For Developers" => [
            "Enhancement Proposals" => "developers/proposals/index.md",
            "Planning Meetings" => "developers/planning-meetings.md",
            "Contribution Guideline" => "developers/contribution-guideline.md",
            "Release Flow" => "developers/release-flow.md",
            "Community" => "developers/community.md"
        ],
        "References" => [
            "API" => "references/apidocs.md",
            "Components" => [
                "mini-lab" => "references/external/mini-lab/README.md",
                "metalctl" => "references/external/metalctl/README.md",
                "csi-driver-lvm" => "references/external/csi-driver-lvm/README.md",
                "firewall-controller" => "references/external/firewall-controller/README.md",
                "tailscale" => "references/external/tailscale/README.md"
            ]
        ]
    ]
)

if is_ci_build
    deploydocs(
        repo = "github.com/metal-stack/docs.git",
        push_preview = true,
    )
end
