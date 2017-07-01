# Restart the WordPress database entirely.

# 1. Restart mysql with innodb_force_recovery = 1
# 4. Run connect.py
# 2. Remove this setting
# 3. Restart mysql
# 5. Copy wordpress to wordpress-backup
# 6. Edit wp-config.php to be correct
# 7. Naviaget to localhost:8888/wordpress and redo installation

# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root"
#   exit
# fi

stop=/Applications/MAMP/bin/stopMysql.sh
start=/Applications/MAMP/bin/startMysql.sh

function restartMysql {
    echo "stopping MySQL..."
    $stop
    sleep 2
    echo "starting MySQL..."
    $start
}

sudo echo 'innodb_force_recovery = 1' >> /etc/my.cnf
restartMysql
sleep 2

sudo sed -i '' -e '$ d' /etc/my.cnf
restartMysql
sleep 2

read -p 'wut'

echo 'creating new database...'
source python/bin/activate
python connect.py

read -p "Press [Enter] key to edit wordpress config"

cd server-files/htdocs

mv wordpress-backup wordpress-backup-prev
cp -r wordpress wordpress-backup
vim wordpress/wp-config.php

chrome-cli open 'http://localhost:8888/wordpress'
