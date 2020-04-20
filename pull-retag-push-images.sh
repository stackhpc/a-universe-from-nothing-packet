#!/bin/bash

set -e

# Reset SECONDS
SECONDS=0

# Install and start docker
yum install docker -y
systemctl enable docker
systemctl start docker

# Start the registry if it does not exist
if [ ! "$(docker ps -q -f name=registry)" ]; then
    docker run -d -p 4000:5000 --restart=always --name registry registry
fi

tag=${1:-train}
images="kolla/centos-binary-kolla-toolbox
kolla/centos-binary-haproxy
kolla/centos-binary-mariadb
kolla/centos-binary-fluentd
kolla/centos-binary-cron
kolla/centos-binary-keepalived
kolla/centos-binary-neutron-server
kolla/centos-binary-neutron-l3-agent
kolla/centos-binary-neutron-metadata-agent
kolla/centos-binary-neutron-openvswitch-agent
kolla/centos-binary-neutron-dhcp-agent
kolla/centos-binary-glance-api
kolla/centos-binary-nova-compute
kolla/centos-binary-keystone-fernet
kolla/centos-binary-keystone-ssh
kolla/centos-binary-keystone
kolla/centos-binary-nova-api
kolla/centos-binary-nova-conductor
kolla/centos-binary-nova-ssh
kolla/centos-binary-nova-novncproxy
kolla/centos-binary-nova-scheduler
kolla/centos-binary-placement-api
kolla/centos-binary-openvswitch-vswitchd
kolla/centos-binary-openvswitch-db-server
kolla/centos-binary-nova-libvirt
kolla/centos-binary-memcached
kolla/centos-binary-rabbitmq
kolla/centos-binary-chrony
kolla/centos-binary-heat-api
kolla/centos-binary-heat-api-cfn
kolla/centos-binary-heat-engine
kolla/centos-binary-horizon
kolla/centos-binary-kibana
kolla/centos-binary-elasticsearch
kolla/centos-binary-barbican-base
kolla/centos-binary-barbican-api
kolla/centos-binary-barbican-worker
kolla/centos-binary-barbican-keystone-listener
kolla/centos-binary-magnum-base
kolla/centos-binary-magnum-api
kolla/centos-binary-magnum-conductor
kolla/centos-source-bifrost-deploy"

for image in $images; do
    docker pull $image:$tag
    docker tag docker.io/$image:$tag localhost:4000/$image:$tag
    docker push localhost:4000/$image:$tag
    docker image remove docker.io/$image:$tag
done

# Duration
duration=$SECONDS
echo "[INFO] $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
