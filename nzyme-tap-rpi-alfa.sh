curl -fsSL https://tailscale.com/install.sh | sh
tailscale up

apt-get install dkms
git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
cd rtl*
make dkms_install

wget https://github.com/nzymedefense/nzyme/releases/download/2.0.0-alpha.12/nzyme-tap_2.0.0-alpha.12_rpios11_arm64.deb
dpkg -i nzyme-tap*

nzyme-tap --generate-channels
nano /etc/nzyme/nzyme-tap.conf

systemctl restart nzyme-tap
journalctl -f -u nzyme-tap
