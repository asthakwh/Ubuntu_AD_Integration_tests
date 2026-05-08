    sudo realm list
    sudo realm leave c3ihub.local -v
    sudo realm list
    sudo systemctl stop sssd
    sudo rm -rf /var/lib/sss/db/*
    sudo rm -rf /etc/sssd/sssd.conf
    sudo kdestroy
    sudo rm -f /etc/krb5.keytab
    sudo apt remove --purge realmd sssd adcli oddjob oddjob-mkhomedir
    sambacommon-bin -y   
    sudo apt autoremove -y
    sudo reboot
    getent passwd | grep c3ihub
    
Remove entry

    Sudo vim /etc/hosts
    Sudo vim /etc/systemd/resolved.conf
    Sudo vim /etc/krb5.conf
