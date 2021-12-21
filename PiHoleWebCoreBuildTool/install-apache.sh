
#sudo apt-get update -y
#sudo apt-get install git make -y
#sudo apt-get install apache2 -y
   
cd /home/pi/

sudo chown -R pi /tmp/install-apache.sh
sudo chown -R pi /tmp/dhcpcd.conf
sudo chown -R pi /tmp/004-pihole.conf
sudo chown -R pi /tmp/setupVars.conf
sudo chown -R pi /tmp/wpa_supplicant.conf

cd /
sudo -u root mkdir /etc/pihole/

cd /tmp/
mv -f wpa_supplicant.conf ~/
mv -f ssh ~/
mv -f setupVars.conf /etc/pihole/

cd /tmp/
mv -f setupVars.conf /etc/pihole/

echo "running pihole install"
cd /home/pi/

if [ -d \"/home/pi/Pi-hole\" ]
then
echo  "Pi-hole exists, removing existing install first"
sudo rm -f -r /home/pi/Pi-hole
else
echo  "Pi-hole folder missing"
fi

if [ -d \"/home/pi/Pi-hole\" ]
then
echo "Pi-hole exists, skipping install" 
else
echo git clone pihole
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"

sudo bash basic-install.sh --disable-install-webserver --unattended
fi

echo  "pihole now installed"

echo  "evaluating webCoRE install "
cd /home/pi/

if [ -d \"/home/pi/webCoRE\" ]
then
echo  "webCoRE exists, removing existing install first"
sudo rm -f -r /home/pi/webCoRE
else
echo  "webCoRE folder missing"
fi

if [ -d \"/home/pi/webCoRE\" ]
then
echo "webCoRE exists, skipping install" 
else
echo git clone webcore
#git clone https://github.com/ajayjohn/webCoRE
#git clone https://github.com/jp0550/webCoRE
git clone https://github.com/imnotbob/webCoRE
fi


cd webCoRE
echo checkout patches
git checkout hubitat-patches
cd dashboard

sudo rm /var/www/webcore
sudo ln -s `pwd` /var/www/webcore

cd ~/
cd /tmp
mv -f 000-default.conf /etc/apache2/sites-available/
mv -f 004-pihole.conf /etc/apache2/sites-available/
mv -f apache2.conf /etc/apache2/


cd /etc/apache2/
sed -i '1s/^\xEF\xBB\xBF//' apache2.conf

sudo chown -R www-data /etc/apache2/sites-available/
sudo chmod 775 '/etc/apache2/sites-available/'
sudo chown www-data /etc/apache2/apache2.conf

sudo find /var/www -type d -exec chmod 2750 {} \+
sudo find /var/www -type f -exec chmod 640 {} \+

sudo chown -R www-data /var/www
sudo chgrp -R www-data /var/www

echo install php
sudo usermod -a -G pihole www-data
sudo apt install php libapache2-mod-php
sudo service apache2 restart


echo "adding hubitat backups chron"

cd /home/pi/
sudo mkdir hubitat
sudo chown pi hubitat
cd hubitat
sudo mkdir backups
sudo chown pi backups

if [ -e \"/etc/cron.daily/backup-hubitat\" ]
then
echo  "backup-hubitat exists, erasing existing script first"
sudo truncate -s 0 /etc/cron.daily/backup-hubitat
fi

echo $'cd /home/pi/hubitat/backups/\nwget --output-document=`date +" % Y -% m -% d"`.lzf http://192.168.0.129/hub/backupDB?fileName=latest' | sudo tee -a /etc/cron.daily/backup-hubitat

echo exit

