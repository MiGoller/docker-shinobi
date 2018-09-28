# Docker image for Shinobi Pro
This docker image is designed to run [Shinobi Pro](https://shinobi.video/pro).
Based on the latest official Node.JS images the build process of the image will clone the current branch of the [Shinobi repository](https://github.com/ShinobiCCTV/Shinobi.git) into the runtime environment. You'll get the current stable Node.JS running the current build of [Shinobi Pro](https://shinobi.video/pro).

Many thanks to [Shinobi Dev Team](https://shinobi.video/pro) for their great work!

Enjoy!

## Shinobi Pro 
Shinobi is the Open Source CCTV Solution written in Node.JS. Designed with multiple account system, Streams by WebSocket, and Save to WebM. Shinobi can record IP Cameras and Local Cameras.

<a href="http://shinobi.video/gallery"><img src="https://github.com/ShinobiCCTV/Shinobi/blob/master/web/libs/img/demo.jpg?raw=true"></a>

## Image flavours
Right now there are two image flavours based on Debian and Alpine Linux. 
With the support of SQLite I'll provide a minimal image for home- or SOHO-use in the future to provide you an out-of-the-box ready to use image.

### Debian based image
This is the default Docker image for Shinobi Pro supporting the following features:
* Choose your database management system. Right now the image supports MySQL, MariaDB and SQLite.
* Shinobi takes use of the default Debian ffmpeg package.
* Well known filesystem structure for scripts, fonts, etc.

### Alpine Linux based image
The Alpine Linux based image provides the same features as the default image but the image size is much smaller.
* Choose your database management system. Right now the image supports MySQL, MariaDB and SQLite.
* Image includes current static build ffmpeg.
* Be aware of the different path- and font-names, if you want to use timestamps. You'll find the [alpine ttf-freefonts](https://pkgs.alpinelinux.org/contents?branch=edge&name=ttf-freefont&arch=x86_64&repo=main) in `/usr/share/fonts/TTF/`.

### Minimal image
The minimal image will only support SQLite as the database management system as the main difference.
* Based on Alpine Linux using the official Node.JS image.
* Image includes current static build ffmpeg.
* Support for timestamps and watermarks.

## Using the image
### Single-container application
You may run Shinobi on Docker as a single-container application. In that case youu will have to grant Shinobi access to aan existing database management system like MySQL or MariaDB.
The `docker cli` is used when managing individual containers on a docker engine. It is the client command line to access the docker daemon api. 
To start Shinobi just type:
```
$ docker run -it --name shinobicctv \
    --link mysql_container:db \
    -p 8080:8080 \
    -e ...
    -e ...
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v /path/to/videos:/opt/shinobi/videos \
    migoller/shinobi:latest
```

If you want to run the Alpine Linux based image take care to the tag `alpine` instead of `latest`: `migoller/shinobi:alpine`.

### Multi-container application
The `docker-compose cli` can be used to manage a multi-container application. It also moves many of the options you would enter on the `docker run cli` into the `docker-compose.yml` file for easier reuse. See this [documentation on docker-compose](https://docs.docker.com/compose/overview/) for more details.

Declare environment variables in `env-files` for easier reuse.

#### Multi-container application including MySQL server
This is an example for a file to run Shinobi with a dedicated MySQL server.
```
version: '2'
services:
  db:
    image: mysql
    env_file:
      - MySQL.env
    volumes:
      - ./datadir:/var/lib/mysql
  web:
    build: .
    env_file:
      - MySQL.env
      - Shinobi.env
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./config:/config
      - ./videos:/opt/shinobi/videos
    depends_on:
      - db
    ports:
      - "8080:8080"
```

#### Multi-container application for each Node.JS application including MySQL server 
This is an example for a file to run Shinobi with a dedicated MySQL server and dedicated containers for each Node.JS application.
```
version: '2'
services:
  db:
    image: mysql
    env_file:
      - MySQL.env
    volumes:
      - ./datadir:/var/lib/mysql
  camera:
    build: .
    env_file:
      - MySQL.env
      - Shinobi.env
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./config:/config
      - ./videos:/opt/shinobi/videos
    depends_on:
      - db
    ports:
      - "8080:8080"
    command: node /opt/shinobi/camera.js
  cron:
    build: .
    env_file:
      - MySQL.env
      - Shinobi.env
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./config:/config
      - ./videos:/opt/shinobi/videos
    depends_on:
      - db
    command: node /opt/shinobi/cron.js
  motion:
    build: .
    env_file:
      - MySQL.env
      - Shinobi.env
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - ./config:/config
      - ./videos:/opt/shinobi/videos
    depends_on:
      - db
    command: node /opt/shinobi/plugins/motion/shinobi-motion.js
```

### Configure the image by environment variables

## HTTPS - SSL encryption for transport security
There are many different possibilities to introduce encryption depending on your setup. 

I recommend using a reverse proxy in front of your installation using the popular [nginx-proxy](https://github.com/jwilder/nginx-proxy) and [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) containers. Please check the according documentations before using this setup.
