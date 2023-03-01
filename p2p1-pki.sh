#!/bin/bash

ip netns add ovpn-server
ip netns add ovpn-client

modprobe veth
ip link add veth0 type veth peer veth1
ip link set veth0 netns ovpn-server
ip link set veth1 netns ovpn-client
ip -n ovpn-server addr add 10.10.10.1/24 dev veth0
ip -n ovpn-client addr add 10.10.10.2/24 dev veth1
ip -n ovpn-server link set veth0 up
ip -n ovpn-client link set veth1 up

#OVPN=/usr/sbin/openvpn
OVPN=${OVPN:-/home/ordex/exp/openvpn_dev/openvpn/src/openvpn/openvpn}

CA=/home/ordex/exp/test-pki/pki/ca.crt
DH=/home/ordex/exp/test-pki/pki/dh.pem
CERT=/home/ordex/exp/test-pki/pki/issued/server.crt
KEY=/home/ordex/exp/test-pki/pki/private/server.key

ip netns exec ovpn-server ${OVPN} \
	--tls-server --ifconfig 10.10.0.1 10.10.0.2 \
	--dev tun \
	--cipher AES-256-GCM \
	--ca ${CA} \
	--cert ${CERT} --key ${KEY} \
	--verb 3 --dh ${DH} $@
