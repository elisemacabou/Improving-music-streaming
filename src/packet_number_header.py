#!/usr/bin/env python3

from scapy.all import *
TYPE_PACKET_NUMBER =0x1212
TYPE_IPV4 = 0x0800

class PacketNumber(Packet):
    MAX_LEN = 1024
    name = 'PacketNumber'
    fields_desc = [
        BitField("packet_number",0,12),
        BitField("ecn",0,2),
        BitField("ran",0,2),
        IntField("subpath", 0),
        ShortField("etherType", 0)
    ]
    
bind_layers(Ether, PacketNumber, type=TYPE_PACKET_NUMBER)
bind_layers(PacketNumber, IP, etherType = TYPE_IPV4)

