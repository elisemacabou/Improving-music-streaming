# Improving Music Streaming

## Files folder:
- Contains different files to send for the server, one of them being the music file
- **CSV files**: 
  - Latency calculation after calculation (latency)
  - Send times
  - Receive times
- **Measurements notebook**: 
  - To do and graph the latencies. Should run and produce good graphs if the main notebook is ran correctly.
- **Rules files**: 
  - Contains the rules for the ingress stage for each switch (s1 is the first switch, s2 is the second switch...)
- **Project notebook**: 
  - Set up the FABRIC slice and topology and run allows sending something from a server (music file and metadata such as how it is set up right now)
- **Scripts folder**: 
  - Contains the necessary scripts to download on the switches for them to be programmable
- **Src**:
  - Contains the P4 program: 
    - The main implementation is in the s3.p4, which handles the rerouting and is only on p3 because of the topology setup. 
    - The other switches are compiled with switch.
  - **Packet_number_header**: 
    - Contains the custom layer implementation
  - **Send.py**: 
    - Script for the server
  - **Recv.py**: 
    - Script for the receiver




















