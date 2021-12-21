echo modify default.conf
cd /etc/apache2/sites-available/
sudo chown -R www-data:www-data 000-default.conf
a2ensite 004-pihole.conf
echo a2enmod
sudo a2enmod rewrite
sudo service apache2 restart
sudo chmod -R /var/www/webcore 400
find /var/www/webcore -type d -exec chmod -R u+x {} \;
sudo chown www-data:www-data /etc/apache2/apache2.conf
sudo chown -R www-data:www-data /etc/apache2/sites-available/
sudo chown www-data:www-data /etc/apache2/apache2.conf
sudo chown www-data:www-data /etc/pihole/setupVars.conf
cd /etc/apache2/
sudo service apache2 reload
echo exit
