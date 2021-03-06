dockerusername=<username>
dockerpassword=<password>
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker.service

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
sudo kubeadm init --pod-network-cidr=10.244.0.0/16


mkdir -p /home/ec2-user/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# curl https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/images/multus-daemonset.yml | kubectl apply -f -

kubeadm token list

kubectl get namespace
kubectl get pods -n kube-system


kubectl create namespace kubernetes-dashboard

kubectl create secret docker-registry regcred --namespace kubernetes-dashboard --docker-server=docker.io --docker-username=$dockerusername --docker-password=$dockerpassword 

kubectl label nodes $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') supermaster=yes

kubectl apply -f deploy-dashboard.yaml
NodePort=$(kubectl get svc kubernetes-dashboard --namespace kubernetes-dashboard -o=jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
NodeIP=$(kubectl get node -o=jsonpath='{.items[?(@.metadata.labels.supermaster=="yes")].status.addresses[?(@.type=="InternalIP")].address}')
kubectl apply -f admin-user.yaml

echo https://$NodeIP:$NodePort

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep clusteradmin | awk '{print $1}') | grep token:

