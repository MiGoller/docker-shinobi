#!/bin/sh
set -e

echo "Copy custom configuration files ..."
if [ -d /config ]; then
    cp -R -f "/config/"* /opt/shinobi || echo "No custom config files found." 
fi

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

echo "Hash admin password ..."
ADMIN_PASSWORD_MD5=$(echo -n "${ADMIN_PASSWORD}" | md5sum | sed -e 's/  -$//')

# set config data from variables
echo "Set MySQL configuration from environment variables ..."
sed -i -e 's/"user": "majesticflame"/"user": "'"${MYSQL_USER}"'"/g' \
       -e 's/"password": ""/"password": "'"${MYSQL_PASSWORD}"'"/g' \
       -e 's/"host": "127.0.0.1"/"host": "'"${MYSQL_HOST}"'"/g' \
       -e 's/"database": "ccio"/"database": "'"${MYSQL_DATABASE}"'"/g' \
       "/opt/shinobi/conf.json"

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
echo "Set the super admin ..."
sed -i -e 's/"mail":"admin@shinobi.video"/"mail":"'"${ADMIN_USER}"'"/g' \
       -e "s/21232f297a57a5a743894a0e4a801fc3/${ADMIN_PASSWORD_MD5}/g" \
       "/opt/shinobi/super.json"

# Execute Command
echo "Starting Shinobi ..."
exec "$@"
