MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==//=="

--==//==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0

#!/bin/bash

echo "${lustre_dns}@tcp:/${lustre_mnt} /fsx lustre defaults,_netdev,flock,user_xattr,noatime,noauto,x-systemd.automount 0 0" >> /etc/fstab
mkdir -p /fsx
chmod a+rwx /fsx
mount /fsx
chmod 777 /fsx
--==//==
