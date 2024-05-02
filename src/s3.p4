/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>
const bit<16> TYPE_IPV4 = 0x800;
const bit<16> TYPE_PACKET_NUMBER = 0x1212;
const bit<19> ECN_THRESHOLD = 10;

const bit<8> RECIRC_FL = 0;

#define PKT_INSTANCE_TYPE_NORMAL 0
#define PKT_INSTANCE_TYPE_INGRESS_CLONE 1
#define PKT_INSTANCE_TYPE_EGRESS_CLONE 2
#define PKT_INSTANCE_TYPE_COALESCED 3
#define PKT_INSTANCE_TYPE_EGRESS_RECIRC 4
#define PKT_INSTANCE_TYPE_REPLICATION 5
#define PKT_INSTANCE_TYPE_RESUBMIT 6

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header packetNumber_t {
    bit<12>   packetNumber;
    bit<2>    ecn;
    bit<2>    ran;
    bit<32>   subpath;
    bit<16>   etherType;
}

/*struct resubmit_meta_t {
   bit<8> i;
}*/

struct metadata {
    //resubmit_meta_t resubmit_meta;
    @Field_list(RECIRC_FL)
    bit <32 > i ;
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    packetNumber_t packetNumber;
}


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

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}

/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
   
    action forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }
    
    action rerouting(macAddr_t dstAddr, egressSpec_t port){
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.dstAddr = hdr.packetNumber.subpath;
    }
    
    action clone_packet() {
        const bit<32> REPORT_MIRROR_SESSION_ID = 500;
        standard_metadata.egress_spec = 0;
        clone(CloneType.I2E, REPORT_MIRROR_SESSION_ID);
        
    }

    action drop() {
        mark_to_drop(standard_metadata);
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr:lpm;
        }
        actions = {
            forward;
            drop;
        }
        size = 1024;
        default_action = drop();
    }
    
     table reroute {
        key = {
            hdr.packetNumber.subpath: lpm;
        }
        actions = {
            rerouting;
            drop;
        }
        size = 1024;
        default_action = drop();
    }
    
   


    apply {
        if(hdr.ipv4.isValid() && standard_metadata.instance_type ==4 && hdr.packetNumber.ecn  == 1  && hdr.packetNumber.subpath != hdr.ipv4.dstAddr){
                clone_packet();
                reroute.apply();
                //ipv4_lpm.apply();
        } else if(hdr.ipv4.isValid()) {
             ipv4_lpm.apply();
        }
    }
}


/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    action clear_ttl() {
        // TTL can be set to 0 only when the packet does not traverse further devices
        // Otherwise compute it to be at least the #devices
        hdr.ipv4.ttl = 0;
    }

    action change_ipv4_addr() {
        hdr.ipv4.srcAddr = 0xc0a8070a;
        hdr.ipv4.dstAddr = 0xc0a8020a;
        hdr.ethernet.srcAddr =000000000007 ;
        hdr.ethernet.dstAddr =000000000002 ;
        
    }
    
    
    action mark_ecn() {
        hdr.packetNumber.ecn = 1;
    }
    
    
    apply { 
        if (hdr.packetNumber.ecn == 0 && hdr.packetNumber.ran ==0 && standard_metadata.instance_type != PKT_INSTANCE_TYPE_INGRESS_CLONE ){
            if (standard_metadata.enq_qdepth >= ECN_THRESHOLD){
                mark_ecn();
                hdr.packetNumber.ran = 1;
                recirculate_preserving_field_list(RECIRC_FL);
            }
        }
        if (standard_metadata.instance_type == PKT_INSTANCE_TYPE_INGRESS_CLONE) {
            change_ipv4_addr();
            clear_ttl();
        }
    
      
   }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	          hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.packetNumber);
        packet.emit(hdr.ipv4);
       
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/
/*Insert the blocks below this comment*/
V1Switch (
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;

