#
# Builds a custom docker image for ShinobiCCTV Pro
#
FROM node:8-alpine 

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
RUN apk add --update --no-cache ffmpeg python pkgconfig cairo-dev make g++ jpeg-dev git ttf-freefont mysql-client wget tar xz
# To-DO: Alpine ffmpeg is missing configuration "--enable-libfreetype"

# Install ffmpeg static build version
RUN wget https://s3.amazonaws.com/cloudcamio/ffmpeg-release-64bit-static.tar.xz

RUN tar xpvf ./ffmpeg-release-64bit-static.tar.xz -C ./ \
    && cp -f ./ffmpeg-3.3-64bit-static/ff* /usr/bin/ \
    && chmod +x /usr/bin/ff*

RUN rm -f ffmpeg-release-64bit-static.tar.xz \
    && rm -rf ./ffmpeg-3.3-64bit-static

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

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2Shinobi.yml"]
