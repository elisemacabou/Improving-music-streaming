#!/usr/bin/env python3
import argparse
import sys
import socket
import random
import struct
import csv
import netifaces as ni
from scapy.all import sendp, send, get_if_list, get_if_hwaddr
from scapy.all import Packet, BitField
from scapy.all import Ether, IP, UDP, TCP
from scapy.all import *
from packet_number_header import PacketNumber
import threading
import binascii
from time import sleep
# Record packet send times
packet_send_times = []
ifaces = []
global dir_path 
global dst_addr
global sub_path
global current_packet
dir_path = '/home/ubuntu/files/'
global dst_addr
dst_addr = socket.gethostbyname('192.168.7.10')

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

def send_data(data):
    received_packets = [];
    global current_packet 
    global dst_addr
    if(data.endswith('.mp3')):
        iface = 'enp6s0' 
        src_addr = socket.gethostbyname('192.168.2.10')
        host_mac_addr =  ni.ifaddresses(iface)[ni.AF_LINK][0]['addr']
        dst = '00:00:00:00:00:07'
        dst_addr = socket.gethostbyname('192.168.7.10')
        
    else:  
        iface = 'enp7s0'
        src_addr = socket.gethostbyname('192.168.1.10')
        host_mac_addr =  ni.ifaddresses(iface)[ni.AF_LINK][0]['addr']
        dst = '00:00:00:00:00:03'
        dst_addr = socket.gethostbyname('192.168.6.10')
        
    data_size = 1024
    file_exists = os.path.exists(dir_path+data)
    if(file_exists):
        with open(dir_path+data, 'rb') as file:
            file_data = file.read()
        num_packets = 100
    else: 
        file_data = data
        num_packets = 1
    for i in range(num_packets):
        start_idx = i * data_size
        end_idx = min((i + 1) * data_size, len(file_data))
        data = file_data[start_idx:end_idx]
        send_time = time.time()
        print(("sending on interface %s to %s" % (iface, str(dst_addr))))
        global subpath
        subpath=0
        if(dst_addr == '192.168.7.10'):
            subpath = struct.unpack('!I', socket.inet_aton('192.168.8.10'))[0]
        pkt =  Ether(src=host_mac_addr, dst=dst)
        pkt = pkt/PacketNumber(packet_number=current_packet,subpath=subpath)/IP(src=src_addr,dst=dst_addr)/UDP(dport=1234, sport=random.randint(49152,65535))/data
   
        # pkt.show()
        sendp(pkt, iface=iface, verbose=False)
        # sleep(1)
        packet_send_times.append([current_packet,send_time])
        current_packet+=1
        # PacketNumber(packet_number=current_packet)
        
    # Save packet send times to CSV file
    csv_file_path = 'packet_send_times.csv'
    with open(csv_file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['PacketNumber','SendTime'])  # Write header
        for packet_number, send_time in packet_send_times:
            writer.writerow([packet_number, send_time])
            

    
            
def congestion(packet):
    if(UDP in packet and packet[IP].dst =='192.168.2.10'):
        if(pkt.ecn == 1):
            print("rerouting...")
            prev_addr = dst_addr
            dst_addr = socket.gethostbyname('192.168.8.10')
            time.sleep(0.05)
            dst_addr = socket.gethostbyname(prev_addr)
    

def sniff_packets():
    sniff(iface="enp6s0", filter="udp", prn=congestion)
    
sniff_thread = threading.Thread(target=sniff_packets)
sniff_thread.start()

def main():

    if len(sys.argv)<2:
        print('pass 2  arguments: "<music>" "<metadata>"')
        exit(1)
    ifaces = [i for i in os.listdir('/sys/class/net/') if 'enp' in i]
    
    global current_packet
    current_packet = 0
    file_path = sys.argv[1]
    send_data(sys.argv[0])
    send_data(file_path)
    
    
    
    
if __name__ == '__main__':
    main()
