Improving Music Streaming


Files folder:
- Contains different files to send for the server, one of them being the music file

- Csv files: latency calculation after calculation(latency), the send times, and the receive times

- Measurements notebook: To do and graph the latencies. Should run and produce good graphs if the main notebook is ran correctly.

- Rules files: contains the rules for the ingress stage for each switch (s1 is the first switch, s2 is the second witch...)

- Project notebook: Set up the FABRIC slice and topology and run allows to send something from a server (music file and metadata such as how it is setup right now)

- Scripts folder: contains the necessary scripts to download on the switches for them to be programmable

- Src:
  - Contains the p4 program: the main implementation is in the s3.p4 which is the program that handles the rerouting and is only on p3 because of the topology setup. The other switch are compiled with switch.
  - Packet_number_header: contains the custom layer implementation
  - Send.py: Script for the server
  - Recv.py: Script for the receiver
   






















