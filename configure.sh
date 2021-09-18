# two namespaces
ip netns add red
ip netns add blue
# the bridge connecting the two namespaces
ip link add bridge0 type bridge
# the veth pair connecting red namespace to the bridge
ip link add veth-red type veth peer name veth-red-br
ip link set veth-red netns red
ip link set veth-red-br master bridge0
# turn the interfaces up
ip -n red link set veth-red up
ip link set veth-red-br up
# do the same for blue namespace
ip link add veth-blue type veth peer name veth-blue-br
ip link set veth-blue netns blue
ip link set veth-blue-br master bridge0
ip -n blue link set veth-blue up
ip link set veth-blue-br up
# turn the bridge up
ip link set bridge0 up
