#! /bin/sh
openvpn --config /etc/openvpn/client/client.conf --ca /etc/openvpn/client/ca.crt --tls-auth /etc/openvpn/client/Wdc.key --auth-user-pass /etc/openvpn/client/auth.txt --script-security 2 --route-up "/bin/sh /etc/openvpn/vpn-up.sh" --down "/bin/sh /etc/openvpn/vpn-down.sh" --verb 4
