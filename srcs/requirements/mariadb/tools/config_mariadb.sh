#!/bin/sh
set -e

# Ensure proper ownership
chown -R mysql:mysql /var/lib/mysql

# Initialize system tables if not present
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🛠️ Initializing MariaDB data directory..."
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm
fi

# Create WordPress database if not exist
if [ ! -d "/var/lib/mysql/wordpress" ]; then
    echo "🧱 Setting up initial WordPress database..."

    cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    /usr/sbin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
    rm -f /tmp/create_db.sql

    echo "✅ Database setup complete"
else
    echo "✅ Database already exists"
fi

# Run the actual server
exec mysqld_safe --user=mysql
