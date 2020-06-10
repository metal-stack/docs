module Docs
    using YAML, HTTP, Markdown, Printf

    export releaseVersion, releaseVector, markdownTemplate, redocTemplate

    redocTpl = raw"""
<!DOCTYPE html>
<html>
<head>
    <title>%s</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">

    <style>
    body {
        margin: 0;
        padding: 0;
    }
    </style>
</head>
<body>
    <redoc spec-url='%s'></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"> </script>
</body>
</html>
"""

    releaseVersion() = get(ENV, "RELEASE_VERSION", "master")
    releaseVector() = release_vector

    r = HTTP.request("GET", string("https://raw.githubusercontent.com/metal-stack/releases/", releaseVersion(), "/release.yaml"))
    release_vector = YAML.load(String(r.body))

    constsprintf(fmt::String, args...) = @eval @sprintf($fmt, $(args...))

    function markdownTemplate(t, x...)
        return Markdown.parse(constsprintf(t, x...))
    end

    function redocTemplate(name, url)
        return constsprintf(redocTpl, name, url)
    end
end
