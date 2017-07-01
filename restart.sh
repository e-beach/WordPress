# This script restarts the WordPress database entirely.
# It recovers from a MySQL error, creates a new database, backs up a copy of wordpress,
# and prompts you to edit the wp-config to increment the database counter.

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

echo 'creating new database...'
source python/bin/activate
python connect.py

read -p "Press [Enter] key to edit wordpress config"

cd server-files/htdocs

mv wordpress-backup wordpress-backup-prev
cp -r wordpress wordpress-backup
vim wordpress/wp-config.php

chrome-cli open 'http://localhost:8888/wordpress'
