# Shinobi CCTV on Docker

[This repository](https://gitlab.com/MiGoller/ShinobiDocker/) provides Docker images regularly built from the [official Shinobi Pro repository](https://gitlab.com/Shinobi-Systems/Shinobi) and additional microservices images, some with hardware acceleration support for NVIDIA or Intel GPUs.

Thank you mrproper, pschmitt & moeiscool for the continuation of the development for the official Docker image.

Find my images on Docker Hub [migoller/shinobi](https://hub.docker.com/r/migoller/shinobi/) and the git repository for upcoming images at https://gitlab.com/MiGoller/ShinobiDocker .

This `README.md` has grown in size. Looks like I'll have to write it down into a Wiki.

## Supported tags

Starting with Docker images enhancing the ["official" ShinobiDocker image](https://gitlab.com/Shinobi-Systems/ShinobiDocker) I provide additional microservices images, some with hardware acceleration support for NVIDIA or Intel GPUs.

### Microservice Shinobi Docker images

Run Shinobi using the "microservice" Shinobi Docker images `microservice-ffmpeg`, `microservice-vaapi`,`microservice-alpine` and `microservice-nvidia` as a stack, connect the Shinobi container to an already existing MariaDB server or run a standalone Shinobi instance with a SQLite database.

You can run a small setups with "microservice" Shinobi Docker images almost out of the box.

- `microservice-alpine`, `0.x.x-microservice-alpine` Shinobi Pro built on Alpine Linux and Alpine FFmpeg [microservice-alpine/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/master/dockerfiles/alpine/Dockerfile)
- `microservice-ffmpeg`, `0.x.x-microservice-ffmpeg` Shinobi Pro built on Ubuntu and FFmpeg [microservice-ffmpeg/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/master/dockerfiles/ffmpeg/Dockerfile)
- `microservice-vaapi`, `0.x.x-microservice-vaapi` Shinobi Pro built on Ubuntu and FFmpeg and Intel VAAPI support [microservice-vaapi/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/master/dockerfiles/vaapi/Dockerfile)
- `microservice-nvidia`, `0.x.x-microservice-nvidia` Shinobi Pro built on Ubuntu and NVIDIA support with preinstalled YOLOv3 plugin. [microservice-nvidia/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/master/dockerfiles/nvidia/Dockerfile)

### All-in-one Shinobi Docker images

The all-in-one images provide the same features as the corresponding microservice images, but they come with a built-in MariDB server. So if you're looking for a single container solution just give it a try.

- `alpine`, `0.x.x-alpine` Shinobi Pro built on Alpine Linux and Alpine FFmpeg [alpine/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-aio/dockerfiles/alpine/Dockerfile)
- `ffmpeg`, `0.x.x-ffmpeg` Shinobi Pro built on Ubuntu and FFmpeg [ffmpeg/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-aio/dockerfiles/ffmpeg/Dockerfile)
- `vaapi`, `0.x.x-vaapi` Shinobi Pro built on Ubuntu and FFmpeg and Intel VAAPI support [vaapi/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-aio/dockerfiles/vaapi/Dockerfile)
- `nvidia`, `0.x.x-nvidia` Shinobi Pro built on Ubuntu and NVIDIA support with preinstalled YOLOv3 plugin. [nvidia/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-aio/dockerfiles/nvidia/Dockerfile)

## Deprecated images and tags

Due to the amount of image variants I decided to stop developing and adding new features to the following images and tags. Right now these images will be part of the continuous builds until end of 2020.

And there are more issues and recommendations:
- Alpine Linux builds still encounter DNS-issues with static FFmpeg builds. 
- Shinobi Systems recommends Ubuntu for installation.
- The "official" image just bundles Shinobi and MariaDB.

> **Warning**:
> I recommend to switch to a supported image variant or tag as soon as possible.

### Official Shinobi Docker images
- `2.0.0-official`, `2.0-official`, `2-official`, `official`, `latest` [master/official/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-official/official/Dockerfile)
- `2.0.0-alpine`, `2.0-alpine`, `2-alpine`, `alpine` [master/alpine/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-official/alpine/Dockerfile)
- `2.0.0-debian`, `2.0-debian`, `2-debian`, `debian` [master/debian/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-official/debian/Dockerfile)

> **Breaking changes**:
> - The tags `latest` and `official` refer to `alpine`.
> - The tag `debian` refer to `ffmpeg`.

### Microservice Shinobi Docker images
- `2.0.0-microservice`, `2.0-microservice`, `2-microservice` [microservice/alpine/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-microservice/alpine/Dockerfile)
- `2.0.0-microservice-debian`, `2.0-microservice-debian`, `12-microservice-debian` [microservice/debian/Dockerfile](https://gitlab.com/MiGoller/ShinobiDocker/-/blob/release-microservice/debian/Dockerfile)

> **Warning**:
> Currently Alpine-based Docker images Shinobi may encounter DNS-resolution issues to hostnames and FQDN with static FFmpeg builds..
> If you encounter such a problem just give the `microservice-alpine` or `microservice-ffmpeg` images a try.

> **Breaking changes**:
> - The tag `microservice` refers to `microservice-alpine`.
> - The tags `microservice-debian` and `microservice-arch` refer to `microservice-ffmpeg`.

## How to Dock Shinobi

If you are looking for how to dock the deprecated images and tags, have a look at the [Shinobi for Docker image variants](IMAGE_VARIANTS.md), please.

Now you have at least two additional options to dock Shinobi.
> I assume that you followed the guide eg. [Get Docker CE for Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/) to install Docker CE. If you do not [Manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/) you'll have to `sudo`the Docker commands.
> The `docker cli` is used when managing individual containers on a docker engine. It is the client command line to access the docker daemon api. 

These are some basic steps to get an container up and running and to persists the containers data.

1. Create a directory for the application.
    This directory may hold the `.service`-files, `docker-compose` files, etc. as well.
2. Create a directory for the application's data like configurations, etc.
    We will mount this directory to a directory inside of the container to persist the container data. So the data will stay even if the container gets removed, updated, etc.
    > The container should be stateless.
3. Run the Docker container for the application.
4. Register the application as a service.

### Which image tag do I have to choose?

Well, it depends. ;-) 
- `alpine` images come without any hardware acceleration support but a small storage foot print.
- `ffmpeg` images are the recommended Ubuntu based images without any hardware acceleration support.
- `vaapi` images come with hardware acceleration support for Intel VA-API GPUs including integrated graphics on CPUs like Intel Pentium G4xxx .
- `nvidia` image come with hardware acceleration support for NVIDIA GPUs providing CUDA and CUVID codecs and features. That's why the YOLOv3 plugin is available out of the box, too.

> **Notice**:
> Ensure you have installed the proper drivers on your Docker host. VA-API or CUDA will not work without a working Docker host setup.


### Dock the current "microservice" Shinobi Docker images `microservice-alpine`, `microservice-ffmpeg`, `microservice-vaapi` and `microservice-nvidia`
Run Shinobi using the "microservice" Shinobi Docker images `microservice-alpine`, `microservice-ffmpeg`, `microservice-vaapi` and `microservice-nvidia` as a stack, connect the Shinobi container to an already existing MariaDB server or run a standalone Shinobi instance with a SQLite database.

#### Run a Shinobi for Docker all-in-one image.

The all-in-one images provide the same features as the corresponding microservice images, but they come with a built-in MariDB server. You can run in it out of the box, but don't forget to mount a local folder or a volume to `/var/lib/mysql` inside of the containter. Otherwise your data will get lost when the container will be removed.

1. First create directories for Shinobi's database, video and configuration files.
    ```shell
    $ mkdir -p [Path to Shinobi direcory]/config [Path to Shinobi direcory]/datadir [Path to Shinobi direcory]/videos
    ```
    
2. Create a `docker-compose.yml` file in the directory `[Path to Shinobi direcory]` with the following content.
    ```yml
    version: '2'
    services:
        app:
            image: migoller/shinobidocker:nvidia
            env_file:
                - Shinobi.env
            environment: 
                - "TZ=Europe/Berlin"
            volumes:
                - /etc/localtime:/etc/localtime:ro
                - /etc/timezone:/etc/timezone:ro
                - ./config:/config
                - ./videos:/opt/shinobi/videos
                - ./datadir:/var/lib/mysql:rw
                - /dev/shm/shinobiDockerTemp:/dev/shm/streams
            ports:
                - "8080:8080"
    ```
    
3. Create `.env`-files to set the environment variables.
    Use `.env`-files to set the environment variables only ones but use them in many containers. We need environment variables to configure Shinobi and MariaDB at runtime, because the container is stateless.
    
    1. Create `MySQL.env` with the following content.
        ```ini
        MYSQL_USER=majesticflame
        MYSQL_PASSWORD=password
        MYSQL_ROOT_PASSWORD=blubsblawoot
        MYSQL_ROOT_USER=root
        EMBEDDEDDB=false
        ```

        > **Notice**:
        > Ensure you set `EMBEDDEDDB=false`. Otherwise your setup will use a local SQLite database.

    2. Create `Shinobi.env` with the following content.
        ```ini
        ADMIN_USER=admin@shinobi.video
        ADMIN_PASSWORD=admin
        CRON_KEY=b59b5c62-57d0-4cd1-b068-a55e5222786f
        PLUGINKEY_MOTION=49ad732d-1a4f-4931-8ab8-d74ff56dac57
        PLUGINKEY_OPENCV=6aa3487d-c613-457e-bba2-1deca10b7f5d
        PLUGINKEY_OPENALPR=SomeOpenALPRkeySoPeopleDontMessWithYourShinobi
        MOTION_HOST=localhost
        MOTION_PORT=8080
        PASSWORD_HASH=sha256
        PRODUCT_TYPE=Pro
        ```
        
4. To start the Shinobi stack just type:
    ```shell
    $ docker-compose up -d
    ```
    If you want to stop the stack run `docker-compose down`.

The stack should be up and running.

#### Run a Shinobi stack on Docker
Well, that's quite easy. A Shinobi stack creates two containers: A container for Shinobi and a second container for Shinobi's private MariaDB server.

1. First create directories for Shinobi's database, video and configuration files.
    ```shell
    $ mkdir -p [Path to Shinobi direcory]/config [Path to Shinobi direcory]/datadir [Path to Shinobi direcory]/videos
    ```
    
2. Create a `docker-compose.yml` file in the directory `[Path to Shinobi direcory]` with the following content.
    ```yml
    version: '2'
    services:
        db:
            image: mariadb
            env_file:
                - MySQL.env
            volumes:
                - ./datadir:/var/lib/mysql
        app:
            # image: migoller/shinobidocker:microservice-alpine
            image: migoller/shinobidocker:microservice-ffmpeg
            # image: migoller/shinobidocker:microservice-vaapi
            # image: migoller/shinobidocker:microservice-nvidia
            env_file:
                - MySQL.env
                - Shinobi.env
            environment: 
                - "TZ=Europe/Berlin"
            volumes:
                - /etc/localtime:/etc/localtime:ro
                - /etc/timezone:/etc/timezone:ro
                - ./config:/config
                - ./videos:/opt/shinobi/videos
                - /dev/shm/shinobiDockerTemp:/dev/shm/streams
            # devices:
            #     - /dev/dri:/dev/dri
            ports:
                - "8080:8080"
    ```
    
3. Create `.env`-files to set the environment variables.
    Use `.env`-files to set the environment variables only ones but use them in many containers. We need environment variables to configure Shinobi and MariaDB at runtime, because the container is stateless.
    
    1. Create `MySQL.env` with the following content.
        ```ini
        MYSQL_USER=majesticflame
        MYSQL_PASSWORD=password
        MYSQL_HOST=db
        MYSQL_PORT=3306
        MYSQL_DATABASE=ccio
        MYSQL_ROOT_PASSWORD=blubsblawoot
        MYSQL_ROOT_USER=root
        EMBEDDEDDB=false
        ```

        > **Notice**:
        > Ensure you set `EMBEDDEDDB=false`. Otherwise your setup will use a local SQLite database.

    2. Create `Shinobi.env` with the following content.
        ```ini
        ADMIN_USER=admin@shinobi.video
        ADMIN_PASSWORD=admin
        CRON_KEY=b59b5c62-57d0-4cd1-b068-a55e5222786f
        PLUGINKEY_MOTION=49ad732d-1a4f-4931-8ab8-d74ff56dac57
        PLUGINKEY_OPENCV=6aa3487d-c613-457e-bba2-1deca10b7f5d
        PLUGINKEY_OPENALPR=SomeOpenALPRkeySoPeopleDontMessWithYourShinobi
        MOTION_HOST=localhost
        MOTION_PORT=8080
        PASSWORD_HASH=sha256
        PRODUCT_TYPE=Pro
        ```
        
4. To start the Shinobi stack just type:
    ```shell
    $ docker-compose up -d
    ```
    If you want to stop the stack run `docker-compose down`.

The stack should be up and running.

##### Run Shinobi against an already existing MariaDB server
Well, that's a bit like a Shinobi stack without a stack. We do not need to launch a private MariaDB server, but we have to connect to an already existing one. Here we go.

> The Shinobi container creates the database on your MariaDB server, creates the user account for Shinobi and sets the required privileges, **if you specify MYSQL_ROOT_USER and MYSQL_ROOT_PASSWORD**.

You're already running a MariaDB server container like this, right?
```shell
$ docker run -d --name [YourMariaDbContainerName] \
    -v /etc/localtime:/etc/localtime:ro \
	-v /etc/timezone:/etc/timezone:ro \
	-v [Path to your MariaDB server data files]:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=[Your very strong MariaDB root password] \
	-p 3306:3306 \
	mariadb
```

1. First create directories for Shinobi's database, video and configuration files.
    ```shell
    $ mkdir -p [Path to Shinobi direcory]/config [Path to Shinobi direcory]/datadir [Path to Shinobi direcory]/videos
    ```
2. To start Shinobi just type:
    ```shell
    $ docker run -d \
        --link [YourMariaDbContainerName]:db \
        -p 8080:8080 \
        -e ADMIN_USER=admin@shinobi.video \
        -e ADMIN_PASSWORD=admin \
        -e PASSWORD_HASH=sha256 \
        -e PRODUCT_TYPE=Pro \
        -e MYSQL_USER=majesticflame\
        -e MYSQL_PASSWORD=password\
        -e MYSQL_HOST=db \
        -e MYSQL_PORT=3306 \
        -e MYSQL_DATABASE=ccio \
        -e MYSQL_ROOT_PASSWORD=[Your very strong MariaDB root password] \
        -e MYSQL_ROOT_USER=[Your MariaDB root username] \
        -e CRON_KEY=b59b5c62-57d0-4cd1-b068-a55e5222786f \
        -e PLUGINKEY_MOTION=49ad732d-1a4f-4931-8ab8-d74ff56dac57 \
        -e PLUGINKEY_OPENCV=6aa3487d-c613-457e-bba2-1deca10b7f5d \
        -e PLUGINKEY_OPENALPR=SomeOpenALPRkeySoPeopleDontMessWithYourShinobi \
        -e MOTION_HOST=localhost \
        -e MOTION_PORT=8080 \
        -v /etc/localtime:/etc/localtime:ro \
        -v /etc/timezone:/etc/timezone:ro \
        -v [Path to your Shinobi data files]/config:/config \
        -v [Path to your Shinobi data files]/videos:/opt/shinobi/videos \
        -v /dev/shm/shinobiDockerTemp:/dev/shm/streams \
        migoller/shinobidocker:microservice-ffmpeg
    ```
    You can accomplish this wit a `docker-compose.yml` file in the directory `[Path to Shinobi direcory]` like this.
    ```yml
    version: '2'
    services:
        app:
            # image: migoller/shinobidocker:microservice-alpine
            image: migoller/shinobidocker:microservice-ffmpeg
            # image: migoller/shinobidocker:microservice-vaapi
            # image: migoller/shinobidocker:microservice-nvidia
            env_file:
                - MySQL.env
                - Shinobi.env
            environment: 
                - "TZ=Europe/Berlin"
            volumes:
                - /etc/localtime:/etc/localtime:ro
                - /etc/timezone:/etc/timezone:ro
                - ./config:/config
                - ./videos:/opt/shinobi/videos
                - /dev/shm/shinobiDockerTemp:/dev/shm/streams
            # devices:
            #     - /dev/dri:/dev/dri
            ports:
                - "8080:8080"
    ```

That's it.

##### Run a Shinobi for Docker with a SQLite database
Well, that's quite easy, too. You will just have to create a single container for Shinobi without any MariaDB setup.

1. First create directories for Shinobi's database, video and configuration files.
    ```shell
    $ mkdir -p [Path to Shinobi direcory]/config [Path to Shinobi direcory]/datadir_sqlite [Path to Shinobi direcory]/videos
    ```
    
2. Create a `docker-compose.yml` file in the directory `[Path to Shinobi direcory]` with the following content.
    ```yml
    version: '2'
    services:
        app:
            # image: migoller/shinobidocker:microservice-alpine
            image: migoller/shinobidocker:microservice-ffmpeg
            # image: migoller/shinobidocker:microservice-vaapi
            # image: migoller/shinobidocker:microservice-nvidia
            env_file:
                - SQLite.env
                - Shinobi.env
            environment: 
                - "TZ=Europe/Berlin"
            volumes:
                - /etc/localtime:/etc/localtime:ro
                - /etc/timezone:/etc/timezone:ro
                - ./datadir_sqlite:/opt/dbdata:rw
                - ./config:/config
                - ./videos:/opt/shinobi/videos
                - /dev/shm/shinobiDockerTemp:/dev/shm/streams
            ports:
                - "8080:8080"

    ```
    
3. Create `.env`-files to set the environment variables.
    Use `.env`-files to set the environment variables only ones but use them in many containers. We need environment variables to configure Shinobi and MariaDB at runtime, because the container is stateless.
    
    1. Create `SQLite.env` with the following content.
        ```ini
        EMBEDDEDDB=true
        ```

    2. Create `Shinobi.env` with the following content.
        ```ini
        ADMIN_USER=admin@shinobi.video
        ADMIN_PASSWORD=admin
        CRON_KEY=b59b5c62-57d0-4cd1-b068-a55e5222786f
        PLUGINKEY_MOTION=49ad732d-1a4f-4931-8ab8-d74ff56dac57
        PLUGINKEY_OPENCV=6aa3487d-c613-457e-bba2-1deca10b7f5d
        PLUGINKEY_OPENALPR=SomeOpenALPRkeySoPeopleDontMessWithYourShinobi
        MOTION_HOST=localhost
        MOTION_PORT=8080
        PASSWORD_HASH=sha256
        PRODUCT_TYPE=Pro
        ```
        
4. To start the Shinobi stack just type:
    ```shell
    $ docker-compose up -d
    ```
    If you want to stop the stack run `docker-compose down`.

The stack of only one container should be up and running.

## Login to Shinobi

The first time start will take a few seconds, because the Shinobi container creates the database on your MariaDB server, creates the user account for Shinobi and sets the required privileges, **if you specify MYSQL_ROOT_USER and MYSQL_ROOT_PASSWORD**.
 
Now try to open Shinobi's super admin UI. Open your Docker host's IP address in your web browser on port `8080`. Open the superuser panel to create an account.
```
Web Address : http://xxx.xxx.xxx.xxx:8080/super
Username : admin@shinobi.video
Password : admin
```
After account creation head on over to the main `Web Address` and start using Shinobi!
```
http://xxx.xxx.xxx.xxx:8080/
```

Enjoy.

##  Shinobi for Docker configuratiom

> **Breaking changes**:
> The new Shinobi for Docker all-in-one images `alpine`, `ffmpeg`, `vaapi` and `nvidia` and the microservice images `microservice-alpine`, `microservice-ffmpeg`, `microservice-vaapi` and `microservice-nvidia` support write-back to your custom `conf.json` file!

Shinobi for Docker uses environment variables for basic or initial setup. But you can provide any existing and customized `conf.json` to the Docker container. Settings you'll modify using the Shinobi Super User's UI will be stored in your `conf.json`. Just mount your `conf.json` into the container per file or per directory:

```yml
version: '2'
services:
    app:
        image: migoller/shinobidocker:microservice-ffmpeg
        env_file:
            - SQLite.env
            - Shinobi.env
        environment: 
            - "TZ=Europe/Berlin"
        volumes:
            - /etc/localtime:/etc/localtime:ro
            - /etc/timezone:/etc/timezone:ro
            - ./datadir_sqlite:/opt/dbdata:rw
            - ./config/conf.json:/opt/shinobi/conf.json
            - ./videos:/opt/shinobi/videos
            - /dev/shm/shinobiDockerTemp:/dev/shm/streams
        ports:
            - "8080:8080"
```
Shinobi for Docker will setup the `/opt/shinobi/conf.json` inside of the container if it's missing or if it's empty.

The container startup script will only try to update the `/opt/shinobi/conf.json` file regarding the provided environment variables.

> **Recommendation**:
> I recommend to set the needed environment variables for initial setup accordingly to your runtime environment.
> - Shinobi will create an initial setup including configuration files like `/opt/shinobi/conf.json` for you. So you can modify the file later on to fit your needs.
> - Just mount a configuration file like `conf.json`on your Docker host to `/opt/shinobi/conf.json` inside of the Shinobi container.

### Shinobi settings

These are the environment variables to setup Shinobi.

| Variable              | Defaults to                                       | Mandatory | Description
|---                    |---                                                |---        |---    
| `ADMIN_USER`          | admin@shinobi.video                               | yes       | The super user's login name.
| `ADMIN_PASSWORD`      | admin                                             | yes       | The super user's secret password.
| `CRON_KEY`            | b59b5c62-57d0-4cd1-b068-a55e5222786f              | no        | Set to a private secret unique key for CRON.
| `PLUGINKEY_MOTION`    | 49ad732d-1a4f-4931-8ab8-d74ff56dac57              | no        | Set to a private secret unique key for motion plugin.
| `PLUGINKEY_OPENCV`    | 6aa3487d-c613-457e-bba2-1deca10b7f5d              | no        | Set to a private secret unique key for opencv plugin.
|`PLUGINKEY_OPENALPR`   | SomeOpenALPRkeySoPeopleDontMessWithYourShinobi    | no        | Set to a private secret unique key for openalpr plugin.
| `MOTION_HOST`         | localhost                                         | no        | Host for motion plugin.
| `MOTION_PORT`         | 8080                                              | no        | Port for motion plugin on `MOTION_HOST`.
| `PASSWORD_HASH`       | sha256                                            | no        | Password hash algorithm [md5 | sha256 | sha512]
| `PRODUCT_TYPE`        |                                                   | no        | Set to `Pro` to enable the Shinobi Pro features.
| `EMBEDDEDDB`          | false                                             | no        | Set to `true` to switch to SQLite database. Otherwise you have to provide MariaDB information.

### MariaDB / MySQL settings

These are the environment variables to setup MariaDB / MySQL for Shinobi.

| Variable              | Defaults to                                       | Mandatory | Description
|---                    |---                                                |---        |---    
| `EMBEDDEDDB`          | false                                             | no        | Enables MariaDB / MySQL backend for Shinobi.
| `MYSQL_USER`          | majesticflame                                     | no        | The Shinobi database username.
| `MYSQL_PASSWORD`      | password                                          | no        | The Shinobi database username's secret password.
| `MYSQL_HOST`          | db                                                | no        | The MariaDB / MySQL host to connect to.
| `MYSQL_PORT`          | 3306                                              | no        | The MariaDB / MySQL port for `MYSQL_HOST`
| `MYSQL_DATABASE`      | ccio                                              | no        | Name of database for Shinobi.
| `MYSQL_ROOT_PASSWORD` | blubsblawoot                                      | no        | Password of MariaDB / MySQL root user account.
| `MYSQL_ROOT_USER`     | root                                              | no        | Username of MariaDB / MySQL root user account.

The first time start will take a few seconds, because the Shinobi container creates the database on your MariaDB server, creates the user account for Shinobi and sets the required privileges, **if you specify MYSQL_ROOT_USER and MYSQL_ROOT_PASSWORD**.

If you set the environment variable `MYSQL_HOST`, Shinobi for Docker will wait at startup for the MariaDB / MySQL Server `MYSQL_HOST` going online. This feature is very useful for Shinobi for Docker stacks with private MariaDB containers.

# HTTPS - SSL encryption for transport security
There are many different possibilities to introduce encryption depending on your setup. 

I recommend using a reverse proxy in front of your installation like the popular [nginx-proxy](https://github.com/jwilder/nginx-proxy) and [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) containers. Please check the according documentations before using this setup.

If you run [Traefik](https://containo.us/traefik/) you can easily put Shinobi for Docker behind the edge router by adding labels to your `docker-compose.yml`.

```yml
labels:
    - "traefik.docker.network=web"
    - "traefik.enable=true"
    - "traefik.basic.frontend.rule=Host:<public FQDN for Shinobi for Docker>"
    - "traefik.basic.port=8080"
    - "traefik.basic.protocol=http"
```

A complete example may look like this `docker-compose.yml`.

```yml
version: '2'
services:
    db:
        image: mariadb
        env_file:
            - MySQL.env
        volumes:
            - ./datadir:/var/lib/mysql
    app:
        image: migoller/shinobidocker:microservice-vaapi
        env_file:
            - MySQL.env
            - Shinobi.env
        environment: 
            - "TZ=Europe/Berlin"
        volumes:
            - /etc/localtime:/etc/localtime:ro
            - /etc/timezone:/etc/timezone:ro
            - ./config:/config
            - ./videos:/opt/shinobi/videos
            - /dev/shm/shinobiDockerTemp:/dev/shm/streams
        devices:
            - /dev/dri:/dev/dri
        ports:
            - "8080:8080"
        labels:
            - "traefik.docker.network=web"
            - "traefik.enable=true"
            - "traefik.basic.frontend.rule=Host:<public FQDN for Shinobi for Docker>"
            - "traefik.basic.port=8080"
            - "traefik.basic.protocol=http"
```

# MIT License

Copyright (c) 2017-2020 MiGoller <goller.michael@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
