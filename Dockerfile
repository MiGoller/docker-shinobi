#   ===========================================================================
#   ---------------------------------------------------------------------------
#                      Based on official Node.JS image
#   ---------------------------------------------------------------------------
#   ===========================================================================

ARG ARG_NODEJS_VERSION="lts"
FROM node:${ARG_NODEJS_VERSION}-alpine

# Build arguments ...

# Image version
ARG ARG_IMAGE_VERSION="3.0.0"

# The channel or branch triggering the build.
ARG ARG_APP_CHANNEL="alpine"

# The commit sha triggering the build.
ARG ARG_APP_COMMIT

# Update Shinobi on every container start?
#   manual:     Update Shinobi manually. New Docker images will always retrieve the latest version.
#   auto:       Update Shinobi on every container start.
ARG ARG_APP_UPDATE=manual

# Build data
ARG ARG_BUILD_DATE

# ShinobiPro branch, defaults to dev
ARG ARG_APP_BRANCH=dev

# Additional Node JS packages for Shinobi plugins, addons, etc.
ARG ARG_ADD_NODEJS_PACKAGES="mqtt"

# Build AIO image?
ARG ARG_AIO="true"

# Create additional directories for: Custom configuration, working directory, database directory, scripts
RUN mkdir -p \
        /opt/shinobi \
        /opt/dbdata \
        /opt/customize

WORKDIR /tmp/workdir

# Install package dependencies
RUN apk update && \
    apk add --no-cache \ 
        freetype-dev \ 
        ffmpeg \
        gnutls-dev \ 
        lame-dev \ 
        libass-dev \ 
        libogg-dev \ 
        libtheora-dev \ 
        libvorbis-dev \ 
        libvpx-dev \ 
        libwebp-dev \ 
        libssh2 \ 
        opus-dev \ 
        rtmpdump-dev \ 
        x264-dev \ 
        x265-dev \ 
        yasm-dev \
        # .build-dependencies \ 
        build-base \ 
        bzip2 \ 
        coreutils \ 
        gnutls \ 
        nasm \ 
        tzdata \
        x264 \
        bind-tools \
        # nscd \
        git \
        make \
        mariadb-client \
        openrc \
        pkgconfig \
        python \
        socat \
        sqlite \
        sqlite-dev \
        wget \
        tar \
        xz \
    #   Nodejs addons
    && npm install -g npm@latest pm2

#   Additional actions for all-in-one images
RUN if [ "$ARG_AIO" = "true" ] ; then \
    apk add --no-cache mariadb openrc; \
	# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql; \
	mkdir -p /var/lib/mysql /run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
	# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /run/mysqld; \
    echo "MariaDB installed."; \
fi

# Assign working directory
WORKDIR /opt/shinobi

# Install Shinobi app including NodeJS dependencies
RUN git clone -b ${ARG_APP_BRANCH} https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi \
    && npm install sqlite3 --unsafe-perm \
    && npm install jsonfile edit-json-file ${ARG_ADD_NODEJS_PACKAGES} \
    && npm install --unsafe-perm \
    && npm audit fix --force

# Copy file system sources
ADD sources/ / 
RUN chmod +x /opt/shinobi/*.sh

# Image settings
VOLUME [ "/opt/dbdata" ]
VOLUME [ "/var/lib/mysql" ]
VOLUME [ "/opt/shinobi/videos" ]

EXPOSE 8080

ENTRYPOINT [ "/opt/shinobi/docker-entrypoint.sh" ]

CMD [ "pm2-docker", "pm2Shinobi.yml" ]

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=${ARG_BUILD_DATE} \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="MiGoller" \
    org.label-schema.vendor="MiGoller" \
    org.label-schema.version="v${ARG_IMAGE_VERSION} (${ARG_APP_CHANNEL}), Node.js v${NODE_VERSION}" \
    org.label-schema.description="Shinobi Pro - The Next Generation in Open-Source Video Management Software" \
    org.label-schema.url="https://github.com/MiGoller/docker-shinobi" \
    org.label-schema.vcs-ref=${ARG_APP_COMMIT} \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/MiGoller/docker-shinobi.git" \
    maintainer="MiGoller" \
    Author="MiGoller"

# Persist app-reladted build arguments
ENV APP_CHANNEL=$ARG_APP_CHANNEL \
    APP_COMMIT=$ARG_APP_COMMIT \
    APP_UPDATE=$ARG_APP_UPDATE \
    APP_BRANCH=${ARG_APP_BRANCH} \
    APP_IMAGE_VERSION=${ARG_IMAGE_VERSION} \
    # Set environment variables to default values
    # ADMIN_USER : the super user login name
    # ADMIN_PASSWORD : the super user login password
    # PLUGINKEY_MOTION : motion plugin connection key
    # PLUGINKEY_OPENCV : opencv plugin connection key
    # PLUGINKEY_OPENALPR : openalpr plugin connection key
    ADMIN_USER=admin@shinobi.video \
    ADMIN_PASSWORD=admin \
    CRON_KEY=fd6c7849-904d-47ea-922b-5143358ba0de \
    PLUGINKEY_MOTION=b7502fd9-506c-4dda-9b56-8e699a6bc41c \
    PLUGINKEY_OPENCV=f078bcfe-c39a-4eb5-bd52-9382ca828e8a \
    PLUGINKEY_OPENALPR=dbff574e-9d4a-44c1-b578-3dc0f1944a3c \
    # Leave these ENVs alone unless you know what you are doing
    MYSQL_USER=majesticflame \
    MYSQL_PASSWORD=password \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=ccio \
    MYSQL_ROOT_PASSWORD=blubsblawoot \
    MYSQL_ROOT_USER=root \
    EMBEDDEDDB=false \
    SUBSCRIPTION_ID= \
    PRODUCT_TYPE= \
    TZ=Europe/Berlin \
    AIO=$ARG_AIO
