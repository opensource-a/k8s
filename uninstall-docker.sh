sudo yum -y remove docker
sudo rm -rf /var/lib/docker
sudo cd /usr/local/bin
sudo rm -rf docker docker-containerd docker-containerd-ctr docker-containerd-shim dockerd docker-proxy docker-runc
sudo cd $home
