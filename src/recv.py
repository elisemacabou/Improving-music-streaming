#!/usr/bin/env python3
import sys
import struct
import os
import csv
from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet, IPOption
from scapy.all import ShortField, IntField, LongField, BitField, FieldListField, FieldLenField
from scapy.all import IP, TCP, UDP, Raw
from scapy.layers.inet import _IPOption_HDR
from packet_number_header import PacketNumber

def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

class IPOption_MRI(IPOption):
    name = "MRI"
    option = 31
    fields_desc = [ _IPOption_HDR,
                    FieldLenField("length", None, fmt="B",
                                  length_of="swids",
                                  adjust=lambda pkt,l:l+4),
                    ShortField("count", 0),
                    FieldListField("swids",
                                   [],
                                   IntField("", 0),
                                   length_from=lambda pkt:pkt.count*4) ]
    


received_packets = []
# Record packet send times
# packet_receive_times = []

def handle_pkt(pkt):
    if UDP in pkt and pkt[UDP].dport == 1234:
        print("got a packet")
        pkt.show()
        receive_time = time.time()
        packet_number = pkt[PacketNumber].packet_number
    #    hexdump(pkt)
        received_packets.append(pkt)
        file_exists = os.path.exists('packet_receive_times.csv')
        with open('packet_receive_times.csv', mode='a', newline='') as file:
            writer = csv.writer(file)
            if not file_exists:  # Write header only if the file is newly created
                writer.writerow(['PacketNumber','ReceiveTime'])  # Header name
            writer.writerow([packet_number,receive_time])


def main():
    ifaces = [i for i in os.listdir('/sys/class/net/') if 'enp' in i]
     # for iface in ifaces:
    # iface= 'enp8s0'
    print("Sniffing on %s" % ifaces)
    sys.stdout.flush()
    sniff(iface=ifaces, prn=lambda x: handle_pkt(x))
    print("Sniffing finished. Total packets received:", len(received_packets))

if __name__ == '__main__':
    main()
