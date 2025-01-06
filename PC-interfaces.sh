#!/bin/sh
sudo docker exec -d clab-srsfc-router1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
sudo docker exec -d clab-srsfc-router3 sysctl -w net.ipv6.conf.all.seg6_enabled=1
sudo docker exec -d clab-srsfc-router4 sysctl -w net.ipv6.conf.all.seg6_enabled=1
sudo docker exec -d clab-srsfc-router1 ip route add 10.0.2.0/24 encap seg6 mode encap segs fc00:31::bb,fc00:32::bb,fc00:4::bb dev eth1
sudo docker exec -d clab-srsfc-router1 ip -6 route add fc00:1::bb/128 encap seg6local action End.DX4 nh4 10.0.0.1 dev eth1
#sudo docker cp /home/em/exp-clab/sr_sfc/deploy-term.sh clab-srsfc-router3:deploy-term.sh
#sudo docker exec -d clab-srsfc-router3 sh deploy-term.sh add vnf1 veth1 inet6 fc00:f1::1/64 fc00:f1::2/64
#sudo docker exec -d clab-srsfc-router3 sh deploy-term.sh add vnf2 veth2 inet6 fc00:f2::1/64 fc00:f2::2/64
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf1 ip link set lo up
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf1 ip addr add fc00:31::1/64 dev lo
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf2 ip link set lo up
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf2 ip addr add fc00:32::1/64 dev lo
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf2 sysctl -w net.ipv6.conf.all.seg6_enabled=1
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf1 ip -6 route add fc00:31::bb/128 encap seg6local action End dev veth0-vnf1
#sudo docker exec -d clab-srsfc-router3 ip netns exec vnf2 ip -6 route add fc00:32::bb/128 encap seg6local action End dev veth0-vnf2
sudo docker exec -d clab-srsfc-router4 ip -6 route add fc00:4::bb/128 encap seg6local action End.DX4 nh4 10.0.2.1 dev eth1
sudo docker exec -d clab-srsfc-router4 ip route add 10.0.0.0/24 encap seg6 mode encap segs fc00:32::bb,fc00:31::bb,fc00:1::bb dev eth1