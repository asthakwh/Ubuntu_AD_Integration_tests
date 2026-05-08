To manually steps if error occured inscript
Domain = example.com
Domain users = joe@example.com, asthak@example.com
   
    sudo apt update
    sudo apt upgrade
    sudo apt install vim
    sudo vim /etc/hosts

127.0.0.1 localhost
127.0.1.1 joe-machine
172.26.234.127 adserver.example.com example or 172.26.234.127
adserver.example.com ad

    sudo cat /etc/hosts
    sudo vim /etc/systemd/resolved.conf
    
[Resolve]
DNS=172.26.234.127
Domains=example.com

    sudo cat /etc/systemd/resolved.conf
    sudo systemctl status systemd-resolved.service
    ping 172.26.234.127
    ping example.com
    sudo apt update
    sudo apt install -y realmd sssd sssd-tools adcli samba-common-bin packagekit
    krb5-user chrony
    sudo realm discover example.com
    sudo vim /etc/krb5.conf

[libdefaults]
udp_preference_limit = 0
default_realm = example.com
dns_lookup_realm = true
dns_lookup_kdc = true
[realms]
example.com = {
#kdc = example.com
#admin_server = example.com(it will auto show some time don’t remove it or add it.)
}
[domain_realm]
= example.com
.example.com = C3



    sudo cat /etc/krb5.conf
    sudo systemctl start sssd realmd chrony
    date  #match date with domain
    sudo apt update
    chronyc tracking

    sudo realm -v join --user=resolve_ad01 example.com
    
(also provide administrator password)


    sudo systemctl restart sssd.service
    sudo systemctl status sssd

    getent passwd
    id asthak@example.com

    sudo su asthak@example.com
    Sudo visio

    su – joe(domain-user)
    sudo apt update
    sudo apt upgrade
    sudo -i
