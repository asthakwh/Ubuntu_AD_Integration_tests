#!/bin/bash
set -e
############################################
# Configuration Section (Edit as needed)
############################################
HOSTNAME="hostname.example.com"
AD_DOMAIN="example.com"
AD_USER="Adminuser"
DNS_IP="172.26.234.127"
ALLOWED_USERS="qAdminuser@example.com,
administrator@example.com, asthak@example.com"
SUDO_USERS= Adminuser@example.com
############################################
# Start Setup
############################################
echo "[*] Updating system packages..."
sudo apt update -y
echo "[*] Installing basic packages..."
sudo apt install -y openssh-server net-tools
echo "[*] Starting SSH service..."
sudo systemctl start ssh
echo "[*] Showing IP information:"
ifconfig || true
echo "[*] Installing AD and realm join packages..."
sudo apt install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli
samba-common-bin oddjob oddjob-mkhomedir packagekit
echo "[*] Pinging AD DNS server ($DNS_IP)..."
ping -c 3 "$DNS_IP" || echo "Warning: DNS server not reachable!"
echo "[*] Updating again (post network config)..."
sudo apt update -y
echo "[*] Setting hostname to $HOSTNAME"
sudo hostnamectl set-hostname "$HOSTNAME"
echo "[*] Disabling systemd-resolved (if interfering)..."
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved.service
echo "[*] Updating /etc/hosts with hostname..."
sudo sed -i "/127.0.1.1/d" /etc/hosts
echo "127.0.1.1 $HOSTNAME" | sudo tee -a /etc/hosts
echo "[*] Configuring DNS in /etc/systemd/resolved.conf..."
sudo bash -c "cat >/etc/systemd/resolved.conf" <<EOF
[Resolve]
DNS=$DNS_IP
FallbackDNS=8.8.8.8
Domains=$AD_DOMAIN
EOF

echo "[*] Restarting systemd-resolved and fixing resolv.conf..."
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "[*] Discovering realm ($AD_DOMAIN)..."
sudo realm discover "$AD_DOMAIN"
echo "[*] Joining AD domain..."
sudo realm join --user="$AD_USER" "$AD_DOMAIN"
echo "[*] Verifying realm join..."
realm list
echo "[*] Permitting AD user: $AD_USER@$AD_DOMAIN"
sudo realm permit "$AD_USER@$AD_DOMAIN"
echo "[*] Checking sssd status..."
systemctl status sssd || true
echo "[*] Ensuring home dir creation is enabled..."
if ! grep -q pam_mkhomedir.so /etc/pam.d/common-session; then
echo 'session required pam_mkhomedir.so skel=/etc/skel
umask=0022' | sudo tee -a /etc/pam.d/common-session
fi
echo "[*] Restarting sssd..."
sudo systemctl restart sssd
echo "[*] Testing AD user resolution (optional)..."
getent passwd 'asthak@c3ihub.local' || echo "User
'asthak@c3ihub.local' not resolved — may not exist or replicated yet."
echo "[*] Updating /etc/sssd/sssd.conf with allowed users..."
sudo bash -c "echo 'simple_allow_users = $ALLOWED_USERS' >>
/etc/sssd/sssd.conf"
sudo systemctl restart sssd
echo "[*] Adding sudoers entry for users..."
for user in $SUDO_USERS; do
echo "$user ALL=(ALL) NOPASSWD: /usr/bin/apt update,
/usr/bin/apt upgrade" | sudo tee -a /etc/sudoers.d/ad_users
done
echo "[✔] AD Integration complete."
