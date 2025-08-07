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

        # Basic information for beginners.
        # Aim to link to deeper and more specialized resources.
        "General" => [
            # these paths need to be kept
            # otherwise existing links will break and degrade search results
            "Getting Started" => "getting-started.md",
            "Why metal-stack" => "concepts/why-metal-stack.md",
            "Why Bare Metal" => "concepts/why-bare-metal.md",

            "Flavors of metal-stack" => "general/flavors-of-metal-stack.md",
        ],
        # Specific for non-operators that use metal-stack.
        # Keep top level pages as minimal as possible.
        "For Users" => [
            "Client Libraries" => "users/client-libraries.md",
        ],

        # The main section for anyone managing metal-stack.
        # Assume Kubernetes knowledge.
        "For Operators" => [
            "Supported Hardware" => "operators/hardware.md",
            "Operating Systems" => "operators/operating-systems.md",
            "Deployment Guide" => "operators/deployment-guide.md",
            "Maintenance" => "operators/maintenance.md",
            "Troubleshoot" => "operators/troubleshoot.md"
        ],

        # Describes all concepts.
        # Do not get into details that might change regularly.
        "Concepts" => [
            "Architecture" => "concepts/architecture.md",
            "User Management" => "concepts/user-management.md",
            "Network" => [
                "Theory" => "concepts/network/theory.md",
                "Firewalls" => "concepts/network/firewalls.md"
            ],
            "Kubernetes" => [
                "Gardener" => "concepts/kubernetes/gardener.md",
                "Cluster API" => "concepts/kubernetes/cluster-api.md",
                "Cloud Controller Manager" => "concepts/kubernetes/cloud-controller-manager.md",
                "Firewall Controller Manager" => "concepts/kubernetes/firewall-controller-manager.md",
                "Isolated Cluster" => "concepts/kubernetes/isolated-clusters.md",
                "GPU Workers" => "concepts/kubernetes/gpu-workers.md",
                "Storage" => "concepts/kubernetes/storage.md"
            ]
        ],

        # For non-technical users.
        # Describes compliance related docs.
        "For CISOs" => [
            "Security" => [
                "cisos/security/principles.md",
                "cisos/security/sbom.md",
                "cisos/security/cryptography.md",
                "cisos/security/communication-matrix.md",
            ],
        ],

        # For maintainers.
        # Assume lots of knowledge.
        "For Developers" => [
            "Enhancement Proposals" => "developers/proposals/index.md",
            "Planning Meetings" => "developers/planning-meetings.md",
            "Contribution Guideline" => "developers/contribution-guideline.md",
            "Release Flow" => "developers/release-flow.md",
            "Community" => "developers/community.md"
        ],

        # Mostly auto-generated contents.
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
