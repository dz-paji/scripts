#!/bin/sh
# this script can and only can be used in CentOS7 with KVM virtualization
# install dependencies

yum -y install epel-release
yum -y update
yum -y install mtr traceroute nano screen wget git supervisor cronie libsodium
echo_supervisord_conf > /etc/supervisord.conf
yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel gcc readline readline-devel readline-static \
openssl openssl-devel openssl-static sqlite-devel bzip2-devel bzip2-libs

# install python3

cd ~
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
cat >> ~/.bashrc << EOF
export PATH="/root/.pyenv/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
EOF
source ~/.bashrc
pyenv install 3.7.1
pyenv global 3.7.1

# setup proxy server

git clone https://github.com/dz-paji/shadowsocksr
cd shadowsocksr
pip install -r requestment.txt
cd ~

# gotop

wget -qO- https://github.com/cjbassi/gotop/raw/master/scripts/download.sh | bash
mv gotop /usr/local/bin

# set up bbr

yum install centos-release-xen-48 -y
yum upgrade kernel -y
echo 'net.core.default_qdisc=fq' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a /etc/sysctl.conf
echo '#!/bin/sh' > /etc/profile.d/bbr_status.sh
echo 'lsmod | grep bbr' >> /etc/profile.d/bbr_status.sh
echo 'rm -rf /etc/profile.d/bbr_status.sh' >> /etc/profile.d/bbr_status.sh
sed -i "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-Xen-*.repo
echo 'please reboot your server to active bbr.'
