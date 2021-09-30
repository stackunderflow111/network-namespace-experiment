# switch to root
sudo su

# namespaces communication
ip -n red addr add 192.168.15.2/24 dev veth-red
ip -n blue addr add 192.168.15.3/24 dev veth-blue
ip netns exec red ping 192.168.15.3

# host communication
ip addr add 192.168.15.1/24 dev bridge0
ping 192.168.15.2
ip netns exec red ping 192.168.15.1

# enable red to access the Internet
ip -n red route add default via 192.168.15.1 dev veth-red
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 ! -o bridge0 -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
ip netns exec red ping 8.8.8.8

# run server
ip netns exec red python3 -m http.server 80

# different machine access -- add routing rule
# run the following on the machine "guest"
ip route add 192.168.15.0/24 via 172.16.1.4 dev enp0s8
curl 192.168.15.2:80

# different machine access -- publish port
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.15.2:80
# run the following on the machine "guest"
curl 172.16.1.4:8080

# publish port -- localhost access
iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 192.168.15.2:80
iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL -o bridge0 -j MASQUERADE
sysctl -w net.ipv4.conf.bridge0.route_localnet=1
curl 192.168.15.1:8080
# this is the default IP address to the Internet when running on virtualbox. Change it if you are using a different virtual machine software
curl 10.0.2.15:8080
curl 127.0.0.1:8080

# publish port -- "blue" namespace access
modprobe br_netfilter
sysctl -w net.bridge.bridge-nf-call-iptables=1
ip netns exec blue curl 192.168.15.1:8080

# publish port -- "red" namespace access
iptables -t nat -A POSTROUTING -s 192.168.15.2 -d 192.168.15.2 -p tcp --dport 80 -j MASQUERADE
ip link set veth-red-br type bridge_slave hairpin on
ip netns exec red curl 192.168.15.1:8080