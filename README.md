# K8s Jenkins Terraform

## Table of Contents

- [About](#about)
- [Development](#dev)
- [License](#license)


## About <a name = "about"></a>

Terraform boilerplate Jenkins deployment on top of Kubernetes. No helm.


## Development <a name = "dev"></a>Comprehension Exercises Week 3 Part 1

For local development you must install the following requisites. See [Deploy](#deploy) for notes on how to deploy the project on a live system.

### Prerequisites
First you need to install a local kubernetes cluster. You can use KIND. Follow the  [install instructtions](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) to provide the tool on you local machine. Then create the cluster following the [Kind - Ingress](https://kind.sigs.k8s.io/docs/user/ingress/) tutorial. 

Create a folder to use in the extraMounts configuration (for volumes):
```sh
mkdir /usr/local/share/kind
``` 

Create the cluster:
```sh
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  extraMounts:
  - hostPath: /usr/local/share/kind
    containerPath: /data
EOF
```

Install an ingress controller using their deployment:
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Wait for ingress creation:
```sh
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## License <a name = "license"></a>
[Mozilla Public License Version 2.0](./LICENSE)
