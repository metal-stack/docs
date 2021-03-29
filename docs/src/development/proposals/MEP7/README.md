# Passing environment variables to machines

Originally we looked for a way to pass proxy settings to our metal machines.
But this an edge-case of the general problem of passing environment variables from the machine allocation down to an installed machine and OS.

We could specify those environment variables with the machine allocation, like this:

```bash
metalctl machine allocate ... --env HTTP_PROXY=proxy --env HTTPS_PROXY=proxy --env NO_PROXY=*.internal
```

- `metal-api` allows to specify environment variables during allocation and persists those
- `metal-hammer` writes the environment variables to `/etc/metal/install.yaml`
-  the script that contains OS specific behavior (`install.sh` in `metal-images`) renders those to a special OS dependent file (`/etc/systemd/system.conf` file on systemd based OSes)

/etc/systemd/system.conf
```text
[Manager]
DefaultEnviroment="HTTP_PROXY=proxy" "HTTPS_PROXY=proxy" "NO_PROXY=*.internal"
```

## Expected result

- all standard processes started by the init system of choice have those variables set
- `gardener-extension-provider-metal` may use this to allocate machines with the variables specified for a specific worker group
