ip addr add 10.0.0.1/24 dev eth1
ip route replace default via 10.0.0.2 dev eth1
ip -6 addr add 2001:fa::2/64 dev eth1
ip -6 route replace default via 2001:fa::1 dev eth1