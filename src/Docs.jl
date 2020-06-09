module Docs
    using YAML, HTTP, Markdown, Printf

    export releaseVersion, releaseVector, printMarkdown

    releaseVersion() = "master"
    releaseVector() = release_vector

    r = HTTP.request("GET", string("https://raw.githubusercontent.com/metal-stack/releases/", releaseVersion(), "/release.yaml"))
    release_vector = YAML.load(String(r.body))

    constsprintf(fmt::String,args...) = @eval @sprintf($fmt,$(args...))

    function printMarkdown(t, x...)
        return Markdown.parse(constsprintf(t, x...))
    end
end
