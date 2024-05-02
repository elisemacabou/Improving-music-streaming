echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.2.0/24 => 00:00:00:00:00:02 0" | simple_switch_CLI


echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.4.0/24 => 00:00:00:00:00:10 2" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.3.0/24 => 00:00:00:00:00:12 1" | simple_switch_CLI

echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.7.0/24 => 00:00:00:00:00:10 2" | simple_switch_CLI

echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.8.0/24 => 00:00:00:00:00:12 1" | simple_switch_CLI

echo "table_add MyIngress.reroute MyIngress.rerouting 192.168.8.0/24 => 00:00:00:00:00:12 1" | simple_switch_CLI

echo "table_add MyIngress.reroute MyIngress.rerouting 192.168.7.0/24 => 00:00:00:00:00:07 00:00:00:00:00:10  2" | simple_switch_CLI

echo "mirroring_add 500 0" | simple_switch_CLI

