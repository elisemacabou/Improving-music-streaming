echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.5.0/24 => 00:00:00:00:00:04 0" | simple_switch_CLI
echo "table_add MyIngress.ipv4_lpm MyIngress.forward 192.168.6.0/24 => 00:00:00:00:00:14 1" | simple_switch_CLI
