#
# Builds a custom docker image for ShinobiCCTV Pro
#
FROM node:8-alpine 

LABEL Author="MiGoller"

# Set environment variables to default values
ENV MYSQL_USER=majesticflame \
    MYSQL_PASSWORD=password \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_DATABASE=ccio \
    ADMIN_USER=admin@shinobi.video \
    ADMIN_PASSWORD=administrator \
    CRON_KEY=b59b5c62-57d0-4cd1-b068-a55e5222786f \
    PLUGINKEY_MOTION=49ad732d-1a4f-4931-8ab8-d74ff56dac57 \
    PLUGINKEY_OPENCV=6aa3487d-c613-457e-bba2-1deca10b7f5d \
    PLUGINKEY_OPENALPR=SomeOpenALPRkeySoPeopleDontMessWithYourShinobi \
    MOTION_HOST=localhost \ 
    MOTION_PORT=8080

# Create the custom configuration dir
RUN mkdir -p /config

# Create the working dir
RUN mkdir -p /opt/shinobi

WORKDIR /opt/shinobi

# Install package dependencies
RUN apk add --update --no-cache ffmpeg python pkgconfig cairo-dev make g++ jpeg-dev git ttf-freefont
# To-DO: Alpine ffmpeg is missing configuration "--enable-libfreetype"

# Clone the Shinobi CCTV PRO repo
RUN mkdir master_temp
RUN git clone https://github.com/ShinobiCCTV/Shinobi.git master_temp
RUN cp -R -f master_temp/* .
RUN rm -rf $distro master_temp

# Install NodeJS dependencies
RUN npm install pm2 -g

RUN npm install && \
    npm install canvas moment --unsafe-perm

# Copy code
COPY docker-entrypoint.sh .
COPY pm2Shinobi.yml .

# Copy default configuration files
COPY ./config/conf.sample.json /opt/shinobi/conf.sample.json
COPY ./config/super.sample.json /opt/shinobi/super.sample.json
COPY ./config/motion.conf.sample.json /opt/shinobi/plugins/motion/conf.sample.json

VOLUME ["/opt/shinobi/videos"]
VOLUME ["/config"]

EXPOSE 8080

ENTRYPOINT ["/opt/shinobi/docker-entrypoint.sh"]

CMD ["pm2-docker", "pm2Shinobi.yml"]
