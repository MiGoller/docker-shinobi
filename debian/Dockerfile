#
# Builds a custom docker image for ShinobiCCTV Pro
#
FROM node:8

LABEL Author="MiGoller"

# Set environment variables to default values
ENV ADMIN_USER=admin@shinobi.video \
    ADMIN_PASSWORD=administrator \
    CRON_KEY=fd6c7849-904d-47ea-922b-5143358ba0de \
    PLUGINKEY_MOTION=b7502fd9-506c-4dda-9b56-8e699a6bc41c \
    PLUGINKEY_OPENCV=f078bcfe-c39a-4eb5-bd52-9382ca828e8a \
    PLUGINKEY_OPENALPR=dbff574e-9d4a-44c1-b578-3dc0f1944a3c \
    MOTION_HOST=localhost \ 
    MOTION_PORT=8080 

# Create the custom configuration dir
RUN mkdir -p /config

# Create the working dir
RUN mkdir -p /opt/shinobi

WORKDIR /opt/shinobi

# Install package dependencies
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y ffmpeg python pkg-config libcairo-dev make g++ libjpeg-dev git mysql-client \
    && apt-get clean

# Clone the Shinobi CCTV PRO repo
RUN mkdir master_temp
RUN git clone https://github.com/ShinobiCCTV/Shinobi.git master_temp
RUN cp -R -f master_temp/* .
RUN rm -rf $distro master_temp

# Install NodeJS dependencies
RUN npm install pm2 -g

RUN npm install && \
    npm install canvas@1.6.5 moment --unsafe-perm

# Copy code
COPY docker-entrypoint.sh .
COPY pm2Shinobi.yml .
RUN chmod -f +x ./*.sh

# Copy default configuration files
COPY ./config/conf.sample.json /opt/shinobi/conf.sample.json
COPY ./config/super.sample.json /opt/shinobi/super.sample.json
COPY ./config/motion.conf.sample.json /opt/shinobi/plugins/motion/conf.sample.json

VOLUME ["/opt/shinobi/videos"]
VOLUME ["/config"]

EXPOSE 8080

# Set the user to use when running this image
# See docker-entrypoint.sh on how to change the uid/gid of the user.
#USER node

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2Shinobi.yml"]
