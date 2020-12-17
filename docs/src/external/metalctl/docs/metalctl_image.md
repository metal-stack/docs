# metalctl image

manage images

## Synopsis

os images available to be installed on machines.

## Options

```
  -h, --help   help for image
```

## Options inherited from parent commands

```
      --apitoken string        api token to authenticate. Can be specified with METALCTL_APITOKEN environment variable.
  -c, --config string          alternative config file path, (default is ~/.metalctl/config.yaml).
                               Example config.yaml:
                               
                               ---
                               apitoken: "alongtoken"
                               ...
                               
                               
      --debug                  debug output
  -f, --file string            filename of the create or update request in yaml format, or - for stdin.
                               Example image update:
                               
                               # metalctl image describe ubuntu-19.04 > ubuntu.yaml
                               # vi ubuntu.yaml
                               ## either via stdin
                               # cat ubuntu.yaml | metalctl image update -f -
                               ## or via file
                               # metalctl image update -f ubuntu.yaml
                               
      --kubeconfig string      Path to the kube-config to use for authentication and authorization. Is updated by login.
      --no-headers             do not print headers of table output format (default print headers)
      --order string           order by (comma separated) column(s), possible values: size|id|status|event|when|partition|project
  -o, --output-format string   output format (table|wide|markdown|json|yaml|template), wide is a table with more columns. (default "table")
      --template string        output template for template output-format, go template format.
                               For property names inspect the output of -o json or -o yaml for reference.
                               Example for machines:
                               
                               metalctl machine list -o template --template "{{ .id }}:{{ .size.id  }}"
                               
                               
  -u, --url string             api server address. Can be specified with METALCTL_URL environment variable.
```

## SEE ALSO

* [metalctl](metalctl.md)	 - a cli to manage metal devices.
* [metalctl image apply](metalctl_image_apply.md)	 - create/update a image
* [metalctl image create](metalctl_image_create.md)	 - create a image
* [metalctl image delete](metalctl_image_delete.md)	 - delete a image
* [metalctl image describe](metalctl_image_describe.md)	 - describe a image
* [metalctl image edit](metalctl_image_edit.md)	 - edit a image
* [metalctl image list](metalctl_image_list.md)	 - list all images
* [metalctl image update](metalctl_image_update.md)	 - update a image

##### Auto generated by spf13/cobra on 14-Aug-2020