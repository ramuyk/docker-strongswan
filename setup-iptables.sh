#!/bin/bash
# iptables setup for strongSwan site-to-site VPN
# Run with: sudo bash iptables-setup.sh

# Configuration - edit these variables for your setup
REMOTE_PEER="<remote-ip>"
LOCAL_NET="<local-range-to-be-accessed>/24"
INTERFACE="<interface>"

echo "Setting up iptables rules for VPN..."
echo "  Remote peer: $REMOTE_PEER"
echo "  Local network: $LOCAL_NET"
echo "  Interface: $INTERFACE"
echo ""

# Allow forwarding between VPN and local network
iptables -I FORWARD -s ${REMOTE_PEER}/32 -d ${LOCAL_NET} -m policy --dir in --pol ipsec -j ACCEPT
iptables -I FORWARD -s ${LOCAL_NET} -d ${REMOTE_PEER}/32 -m policy --dir out --pol ipsec -j ACCEPT

# NAT rules - make traffic from remote peer appear to come from VPN server
iptables -t nat -I POSTROUTING -s ${REMOTE_PEER}/32 -o ${INTERFACE} -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -I POSTROUTING -s ${REMOTE_PEER}/32 -o ${INTERFACE} -j MASQUERADE

echo "✓ iptables rules added successfully!"
