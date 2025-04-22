# Expose Services with Tailscale
This guide is a recommendation how to access services from anywhere if you are evaluating the metalstack on-prem starter without a public IP-address.

These steps will guide you through the process quickly. For a deeper dive or if you want use alternative setups, the articles from Tailscale are also linked.

## What are Tailscale and Tailnets?
Tailscale is a Canadian company that offers a virtual private network solution based on WireGuard. 

Instead of relying on centralized VPN-Servers which route all the traffic, Tailscale establishes a mesh VPN called tailnet. It creates encripted peer-to-peer connections between the participants of the network. This approach claims to improve troughput and stability while lowering the latency.

Major parts of Tailscale are OpenSource. Find more information on their [Open Source Statement](https://tailscale.com/opensource) and their [GitHub Repository](https://github.com/tailscale). For open source operating systems, especially 

## Setup an Account and Clients
[Start here](https://login.tailscale.com/start) to use an authentication provider to create the first user account for your network. 

In the first step, install clients for tailscale on devices you want to access the Kubernetes services. 

In the "Users" tab on the Admin Console, you can invite more users to your network.  

## Setup the Operator
### Labels
First, we setup Tags that will label our services. Open the "Access controls" tab, which contains a texteditor with all Access Control Settings in json-format.

Uncomment the `tagOwners` section and add the following tags:
```json
"tagOwners": {
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"],
}
```
The operator will use the `k8s-operator`-tag. Devices with this tag are now configured as owner for devices with the `k8s`-tag, which will be used for our services. 
### Create OAuth-Client Credentials
In the "Settings" tab at "OAuth clients", generate a new OAuth Client. Set write permissions for "Devices - Core" and "Keys - Auth Keys". Select the `k8s-operator` tag for both.

IMAGEPLACEHOLDER DEVICES

IMAGEPLACEHOLDER KEYS


 Hence a `k8s-operator`-taged device will be able to register further devices with the `k8s` tag.

When you click "create", you get a client-id and client-secret, that you will need to setup the operator.
### Setup Operator with helm
The most common and practical way is to use a helm-chart to setup the operator.
Therefore, we first have to add and update the helm-repository of tailscale:
```
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update
```

Now, we can install the helm-chart in a dedicated namespace using the credentials of the OAuthClient

```bash
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId="<OAauth client ID>" \
  --set-string oauth.clientSecret="<OAuth client secret>" \
  --wait
```
Check on the administration console, if your operator appears on the Machines-list.

Alternative ways & troubleshooting:
- Take the [operator.yaml manifest](https://github.com/tailscale/tailscale/blob/main/cmd/k8s-operator/deploy/manifests/operator.yaml) from the GitHub-Repository and make your adjustments to use [Static manifests with kubectl](https://tailscale.com/kb/1236/kubernetes-operator#static-manifests-with-kubectl)
- If the operator does not show op in the Machines-list, use the Guide for [Troubleshooting the Kubernetes operator](https://tailscale.com/kb/1446/kubernetes-operator-troubleshooting)
## Expose Services on the Tailnet
### Use add aLoad Balancer Service
The installed operator is looking for Ingress-objects with the `spec.type`of `LoadBalancer`and the `spec.loadBalancerClass` of `tailscale`. 
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
    - name: https
      port: 443
      targetPort: 443
  type: LoadBalancer
  loadBalancerClass: tailscale
```
### Annotate an existing Servie
Edit the Service and under metadata.annotations, add the annotation tailscale.com/expose with the value "true":
```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    tailscale.com/expose: "true"
  name: nginx
spec:
  ...
```

 Note that "true" is quoted because annotation values are strings, and an unquoted true will be incorrectly interpreted as a boolean.
### Use an Ingress
To enable path-based routing, use an Ingress resource. 
Ingress routes only use TLS over HTTPS. To make this work, you have to enable the `MagicDNS` and `HTTPS` options in the "TAB" on your "SETTINGS PAGE".
IMAGEPLACEHOLDER 
To set it up, refer to `tailscale` as the `ingressClassName`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
spec:
  ingressClassName: tailscale
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
  ...
```
Please consider, that currently only paths with `pathType: prefix` are supported currently