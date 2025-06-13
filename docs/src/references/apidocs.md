# API Documentation

In this section you will find links to the API documentation of metal-stack components.

```@eval
using Docs

metal_api_image = releaseVector()["docker-images"]["metal-stack"]["control-plane"]["metal-api"]["tag"]
content = redocTemplate("metal-api", string("https://raw.githubusercontent.com/metal-stack/metal-api/", metal_api_image, "/spec/metal-api.json"))

f = open(string(@__DIR__, "/metal-api/index.html"), "w")
write(f, content)
close(f);

nothing
```

- [metal-api](metal-api/index.html)
