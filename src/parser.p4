#include "headers.p4"

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }
    

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            TYPE_PACKET_NUMBER: parse_packet_number;
            default: accept;
        }
    }
    state parse_packet_number {
        packet.extract(hdr.packetNumber); // Extract the PacketNumber header
        transition select(hdr.packetNumber.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
         }
       
     }
        
     state parse_ipv4 {
       packet.extract(hdr.ipv4);
       transition accept; 
       }

    /*state parse_ipv4 {
       packet.extract(hdr.ipv4);
       transition select(hdr.ipv4.protocol){
           TYPE_PACKET_NUMBER: parse_packet_number;
           default: accept;
       }
    }

    state parse_packet_number {
        packet.extract(hdr.packetNumber); // Extract the PacketNumber header
        transition accept;
    }*/

}

