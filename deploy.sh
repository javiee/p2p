
#!/bin/sh

K8_CLUSTER="p2p-cluster"

installKind(){
    if ! command kind 2>&1 >/dev/null
    then    
        echo "Installing kind"
        [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
        # For ARM64
        [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-arm64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    fi
}

installKubectl() {

    if ! command kubectl 2>&1 >/dev/null
    then
        echo "installing kubectl"
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
    fi

}

installHelm() {
    if ! command helm 2>&1 >/dev/null
    then
        echo "installing helm"
        curl -LO "https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz"
        tar -xvf helm-v3.16.3-linux-amd64.tar.gz 
        chmod +x linux-amd64/helm
        mv linux-amd64/helm /usr/local/bin/helm
        rm -rf linux-amd64/ helm-*
    fi
    
}


installKubectl
installHelm
installKind

if sudo kind get clusters | grep -q "^p2p-cluster$"; then
    echo "Cluster 'p2p-cluster' exists"
    kubectl cluster-info --context kind-p2p-cluster
        
else
    echo "Cluster 'p2p-cluster' does not exist, creating!"
    kind create cluster --name p2p-cluster
    sudo kind get kubeconfig --name p2p-cluster >> $HOME/.kube/config
    kubectl cluster-info --context kind-p2p-cluster
fi

