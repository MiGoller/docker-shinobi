#!/bin/sh
set -e

# Copy existing custom configuration files
echo "Copy custom configuration files ..."
if [ -d /config ]; then
    cp -R -f "/config/"* /opt/shinobi || echo "No custom config files found." 
fi

# Create default configurations files from samples if not existing
if [ ! -f /opt/shinobi/conf.json ]; then
    echo "Create default config file /opt/shinobi/conf.json ..."
    cp /opt/shinobi/conf.sample.json /opt/shinobi/conf.json
fi

if [ ! -f /opt/shinobi/super.json ]; then
    echo "Create default config file /opt/shinobi/super.json ..."
    cp /opt/shinobi/super.sample.json /opt/shinobi/super.json
fi

if [ ! -f /opt/shinobi/plugins/motion/conf.json ]; then
    echo "Create default config file /opt/shinobi/plugins/motion/conf.json ..."
    cp /opt/shinobi/plugins/motion/conf.sample.json /opt/shinobi/plugins/motion/conf.json
fi

# Hash the admins password
if [ -n "${ADMIN_PASSWORD}" ]; then
    echo "Hash admin password ..."
    ADMIN_PASSWORD_MD5=$(echo -n "${ADMIN_PASSWORD}" | md5sum | sed -e 's/  -$//')
fi

# Create MySQL database if it does not exists
if [ -n "${MYSQL_HOST}" ]; then
    echo "Wait for MySQL server" ...
    while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
        sleep 1
    done
fi

if [ -n "${MYSQL_ROOT_USER}" ]; then
    if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
        echo "Setting up MySQL database if it does not exists ..."

        mkdir -p sql_temp
        cp -f ./sql/framework.sql ./sql_temp
        cp -f ./sql/user.sql ./sql_temp

        if [ -n "${MYSQL_DATABASE}" ]; then
            echo "Modifying database name ..."
            sed -i  -e "s/ccio/${MYSQL_DATABASE}/g" \
                "./sql_temp/framework.sql"
            
            sed -i  -e "s/ccio/${MYSQL_DATABASE}/g" \
                "./sql_temp/user.sql"
        fi

        if [ -n "${MYSQL_ROOT_USER}" ]; then
            if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
                echo "Modifying user creation script ..."
                sed -i -e "s/majesticflame/${MYSQL_USER}/g" \
                    -e "s/\x27\x27/\x27${MYSQL_PASSWORD}\x27/g" \
                    -e "s/127.0.0.1/%/g" \
                    "./sql_temp/user.sql"
            fi
        fi

        echo "Create database schema if it does not exists ..."
        mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "source ./sql_temp/framework.sql" || true

        echo "Create database user if it does not exists ..."
        mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "source ./sql_temp/user.sql" || true

        rm -rf sql_temp
    fi
fi

# set config data from variables
echo "Set MySQL configuration from environment variables ..."
if [ -n "${MYSQL_USER}" ]; then
    echo "  . Username"
    sed -i -e 's/"user": "majesticflame"/"user": "'"${MYSQL_USER}"'"/g' \
        "/opt/shinobi/conf.json"
fi

if [ -n "${MYSQL_PASSWORD}" ]; then
    echo "  . Password"
    sed -i -e 's/"password": ""/"password": "'"${MYSQL_PASSWORD}"'"/g' \
        "/opt/shinobi/conf.json"
fi

if [ -n "${MYSQL_HOST}" ]; then
    echo "  . Host"
    sed -i -e 's/"host": "127.0.0.1"/"host": "'"${MYSQL_HOST}"'"/g' \
        "/opt/shinobi/conf.json"
fi

if [ -n "${MYSQL_DATABASE}" ]; then
    echo "  . Database"
    sed -i -e 's/"database": "ccio"/"database": "'"${MYSQL_DATABASE}"'"/g' \
        "/opt/shinobi/conf.json"
fi

echo "Set keys for CRON and PLUGINS from environment variables ..."
sed -i -e 's/"key":"73ffd716-16ab-40f4-8c2e-aecbd3bc1d30"/"key":"'"${CRON_KEY}"'"/g' \
       -e 's/"Motion":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"Motion":"'"${PLUGINKEY_MOTION}"'"/g' \
       -e 's/"OpenCV":"644bb8aa-8066-44b6-955a-073e6a745c74"/"OpenCV":"'"${PLUGINKEY_OPENCV}"'"/g' \
       -e 's/"OpenALPR":"9973e390-f6cd-44a4-86d7-954df863cea0"/"OpenALPR":"'"${PLUGINKEY_OPENALPR}"'"/g' \
       "/opt/shinobi/conf.json"

echo "Set configuration for motion plugin from environment variables ..."
sed -i -e 's/"host":"localhost"/"host":"'"${MOTION_HOST}"'"/g' \
       -e 's/"port":8080/"port":"'"${MOTION_PORT}"'"/g' \
       -e 's/"key":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"key":"'"${PLUGINKEY_MOTION}"'"/g' \
       "/opt/shinobi/plugins/motion/conf.json"

# Set the admin password
if [ -n "${ADMIN_USER}" ]; then
    if [ -n "${ADMIN_PASSWORD_MD5}" ]; then
        sed -i -e 's/"mail":"admin@shinobi.video"/"mail":"'"${ADMIN_USER}"'"/g' \
            -e "s/21232f297a57a5a743894a0e4a801fc3/${ADMIN_PASSWORD_MD5}/g" \
            "/opt/shinobi/super.json"
    fi
fi

# Change the uid/gid of the node user
if [ -n "${GID}" ]; then
    if [ -n "${UID}" ]; then
        groupmod -g ${GID} node && usermod -u ${UID} -g ${GID} node
    fi
fi

# Execute Command
echo "Starting Shinobi ..."
exec "$@"
