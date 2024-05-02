echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.4.0/24 => 00:00:00:00:00:09 0" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.7.0/24 => 00:00:00:00:00:15 1" | simple_switch_CLI

