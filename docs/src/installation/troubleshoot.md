# Troubleshoot

This document summarizes help when something goes wrong and provides advice on debugging the metal-stack in certain situations.

If you still can't find a solution to your problem, please reach out to us and our community. We have a public Slack Channel to discuss problems, but you can also reach us via mail. Check out [metal-stack.io](https://metal-stack.io) for contact information.

```@contents
Pages = ["troubleshoot.md"]
Depth = 5
```

## Deployment

### Ansible fails when the metal control plane helm chart gets applied

There can be many reasons for this. Since you are deploying the metal control plane into a Kubernetes cluster, the first step should be to install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and check the pods in your cluster. Depending on the metal-stack version and Kubernetes cluster, your control-plane should look something like this after the deployment (this is in a Kind cluster):

```bash
kubectl get pod -A
NAMESPACE             NAME                                         READY   STATUS      RESTARTS   AGE
ingress-nginx         nginx-ingress-controller-56966f7dc7-khfp9    1/1     Running     0          2m34s
kube-system           coredns-66bff467f8-grn7q                     1/1     Running     0          2m34s
kube-system           coredns-66bff467f8-n7n77                     1/1     Running     0          2m34s
kube-system           etcd-kind-control-plane                      1/1     Running     0          2m42s
kube-system           kindnet-4dv7m                                1/1     Running     0          2m34s
kube-system           kube-apiserver-kind-control-plane            1/1     Running     0          2m42s
kube-system           kube-controller-manager-kind-control-plane   1/1     Running     0          2m42s
kube-system           kube-proxy-jz7kp                             1/1     Running     0          2m34s
kube-system           kube-scheduler-kind-control-plane            1/1     Running     0          2m42s
local-path-storage    local-path-provisioner-bd4bb6b75-cwfb7       1/1     Running     0          2m34s
metal-control-plane   ipam-db-0                                    2/2     Running     0          2m31s
metal-control-plane   masterdata-api-6dd4b54db5-rwk45              1/1     Running     0          33s
metal-control-plane   masterdata-db-0                              2/2     Running     0          2m29s
metal-control-plane   metal-api-998cb46c4-jj2tt                    1/1     Running     0          33s
metal-control-plane   metal-api-initdb-r9sc6                       0/1     Completed   0          2m24s
metal-control-plane   metal-api-liveliness-1590479940-brhc7        0/1     Completed   0          6s
metal-control-plane   metal-console-7955cbb7d7-p6hxp               1/1     Running     0          33s
metal-control-plane   metal-db-0                                   2/2     Running     0          2m34s
metal-control-plane   nsq-lookupd-5b4ccbfb64-n6prg                 1/1     Running     0          2m34s
metal-control-plane   nsqd-6cd87f69c4-vtn9k                        2/2     Running     0          2m33s
```

If there are any failing pods, investigate those and look into container logs. This information should point you to the place where the deployment goes wrong.

!!! info

    Sometimes, you see a helm errors like "no deployed releases" or something like this. When a helm chart fails after the first deployment it could be that you have a chart installation still pending. Also, the control plane helm chart uses pre- and post-hooks, which creates [jobs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) that helm expects to be completed before attempting another deployment. Delete the helm chart (use Helm 3) with `helm delete -n metal-control-plane metal-control-plane` and delete the jobs in the `metal-control-plane` namespace before retrying the deployment.
