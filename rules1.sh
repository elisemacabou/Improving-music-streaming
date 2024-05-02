echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.1.0/24 => 00:00:00:00:00:01 0" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.6.0/24 => 00:00:00:00:00:05 1" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.5.0/24 => 00:00:00:00:00:05 1" | simple_switch_CLI
