sudo kubeadm reset

sudo systemctl stop docker && sudo systemctl stop kubelet

sudo rm -rf /etc/kubernetes

sudo rm -rf .kube

sudo rm -rf /var/lib/kubelet

sudo rm -rf /var/lib/cni

sudo rm -rf /etc/cni

sudo rm -rf /var/lib/etcd

sudo systemctl start docker && sudo systemctl start kubelet
