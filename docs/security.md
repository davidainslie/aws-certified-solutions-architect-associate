# Security

## DDoS

A Distributed Denial of Service (DDoS) attack is an attack that attempts to make your website or application unavailable to your end users.
This can be achieved by multiple mechanisms, such as large packet floods, by using a combination of reflection and amplification techniques, or by using large botnets.

SYN flood attack i.e. Layer 4 DDoS attack:
- A layer 4 DDoS attack is often referred to as a `SYN flood`; it works at the transport layer (TCP).
- To establish a TCP connection a 3-way handshake takes place; the client sends a SYN packet to a server, the server replies with a SYN-ACK, and the client then responds to that with an ACK.
- What should happen?
  - After the 3-way handshake is complete, the TCP connection is established; after this, applications begin sending data using Layer 7 (application layer protocol), such as HTTP etc.
- SYN floods:
  - A SYN flood uses the built in patience of the TCP stack to overwhelm a server by sending a large number of SYN packets and then ignoring the SYN-ACKs returned by the server.
  - This causes the server to use up resources waiting for a set amount of time for the anticipated ACK that should come from a legitimate client.
- What can happen?
  - There are only so many concurrent TCP connections that a web or application server can have open, so if an attacker sends enough SYN packets to a server, it can easily eat through the allowed number of TCP connections.
  - This then prevents legitimate requests from being answered by the server.

Amplification attack:
- Amplification/reflection attacks can include things such as NTP, SSDP, DNS, CharGEN, SNMP attacks, etc.
- This is where an attacker may send a third-party server (such as an NTP server) a request using a spoofed IP address.
- The server then responds to the request with a greater payload (than original request), usually around 28-64 times larger, back to the spoofed IP address.
- This means that if the attacker sends a packet with a spoofed IP address of 64 bytes, the NTP server would respond with up to 3,456 bytes of traffic.
- Attackers can coordinate this and use multiple NTP servers a second to send legitimate NTP traffic to the target.

![Spoofing](images/spoofing.jpg)

Layer 7 attack:
- A Layer 7 attack occurs where a webserver receives a flood of GET or POST requests, usually from a botnet or a large number of compromised computers.

## Logging API calls with CloudTrail

- AWS CloudTrail increases visibility into your user and resource activity by recording AWS management console actions and API calls.
- You can identify which users and accounts called AWS, the source IP address from which the calls were made, and when the calls occurred.
- The logs are stored in S3.

## Protecting applications with Shield
