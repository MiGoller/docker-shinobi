# Shinobi for Docker hardware acceleration
To get the power of your GPU into your Shinobi container you will have to use the hardware acceleration enabled images `vaapi` and `nvidia`.

Many Thanks to [Julien Rottenberg](https://github.com/jrottenberg) for his hardware acceleration enabled [FFmpeg Docker images](https://github.com/jrottenberg/ffmpeg) [jrottenberg/ffmpeg:vaapi](https://hub.docker.com/r/jrottenberg/ffmpeg) and [jrottenberg/ffmpeg:nvidia](https://hub.docker.com/r/jrottenberg/ffmpeg) .

## Intel VA-API support

Run the container with the device attached `/dev/dri` from your host into the container:

```shell
$ docker run \
    --device /dev/dri:/dev/dri \ 
    [...]
```

If you are using `docker-compose` you will have to add the device mapping to your `docker-compose.yml`.

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
        image: migoller/shinobidocker:vaapi
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
```

> **You must have the Intel drivers up and running on your host.**
> You can run vainfo (part of vainfo package on Ubuntu) to determine whether your graphics card has been recognized correctly.

```shell
$ sudo vainfo
error: XDG_RUNTIME_DIR not set in the environment.
error: can't connect to X server!
libva info: VA-API version 0.39.4
libva info: va_getDriverName() returns 0
libva info: Trying to open /usr/lib/x86_64-linux-gnu/dri/i965_drv_video.so
libva info: Found init function __vaDriverInit_0_39
libva info: va_openDriver() returns 0
vainfo: VA-API version: 0.39 (libva 1.7.3)
vainfo: Driver version: Intel i965 driver for Intel(R) Skylake - 1.7.0
vainfo: Supported profile and entrypoints
      VAProfileMPEG2Simple            : VAEntrypointVLD
      VAProfileMPEG2Simple            : VAEntrypointEncSlice
      VAProfileMPEG2Main              : VAEntrypointVLD
      VAProfileMPEG2Main              : VAEntrypointEncSlice
      VAProfileH264ConstrainedBaseline: VAEntrypointVLD
      VAProfileH264ConstrainedBaseline: VAEntrypointEncSlice
      VAProfileH264Main               : VAEntrypointVLD
      VAProfileH264Main               : VAEntrypointEncSlice
      VAProfileH264High               : VAEntrypointVLD
      VAProfileH264High               : VAEntrypointEncSlice
      VAProfileH264MultiviewHigh      : VAEntrypointVLD
      VAProfileH264MultiviewHigh      : VAEntrypointEncSlice
      VAProfileH264StereoHigh         : VAEntrypointVLD
      VAProfileH264StereoHigh         : VAEntrypointEncSlice
      VAProfileVC1Simple              : VAEntrypointVLD
      VAProfileVC1Main                : VAEntrypointVLD
      VAProfileVC1Advanced            : VAEntrypointVLD
      VAProfileNone                   : VAEntrypointVideoProc
      VAProfileJPEGBaseline           : VAEntrypointVLD
      VAProfileJPEGBaseline           : VAEntrypointEncPicture
      VAProfileVP8Version0_3          : VAEntrypointVLD
      VAProfileVP8Version0_3          : VAEntrypointEncSlice
      VAProfileHEVCMain               : VAEntrypointVLD
      VAProfileHEVCMain               : VAEntrypointEncSlice
```

Now you can enable hardware acceleration in Shinobi's monitors' settings. Select the right codec for encoding and don't forget to set the corresponding device e.g. `/dev/drv/renderD128` in the monitors' hardware acceleration setup.

## NVIDIA CUDA and CUVID support

Use FFmpeg version >= 4.0 to enable hardware decoding and scaling.

### Enable the Docker host to let container use the NVIDIA GPU.

Please have a look at https://github.com/NVIDIA/nvidia-docker for detailed instructions on how to enable CUDA support for your Docker host. This is just a brief summary.

1.  Install latest [NVIDIA drivers](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver) on host machine.
2.  Install [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) on host machine. NVIDIA provides a detailed README.md on how to get your Docker host ready for NVIDIA GPU power.
3.  Modify your Docker host setup regarding issue [Support for NVIDIA GPUs under Docker Compose #6691](https://github.com/docker/compose/issues/6691)

    Check your `/etc/docker/daemon.json` for the following settings.
    ```yml
    {
        "runtimes": {
            "nvidia": {
                "path": "/usr/bin/nvidia-container-runtime",
                "runtimeArgs": []
            }
        }
    }
    ```

### Run container using `--runtime=nvidia` flag

```shell
$ docker run \
    --runtime=nvidia \ 
    [...]
```

If you are using `docker-compose` you will have to add the device mapping to your `docker-compose.yml`.

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
        image: migoller/shinobidocker:nvidia
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
        runtime: nvidia
        ports:
            - "8080:8080"
```

> **Warning**:
> There is an open issue regarding using `runtime: nvidia` in `docker-compose.yml`: [Support for NVIDIA GPUs under Docker Compose #6691](https://github.com/docker/compose/issues/6691). Right now you have to modify your Docker setup to enable the `runtime: nvidia` option in your `docker-compose.yml` files.

#  Validate the image's hardware acceleration
Running the following commands inside the Docker container will show you the current hardware acceleration support.

1. Lets have a look at the supported hardware acceleration drivers: `ffmpeg -hwaccels`
    ```shell
    $  ffmpeg -hwaccels
    ffmpeg version 4.2.2 Copyright (c) 2000-2019 the FFmpeg developers
    built with gcc 7 (Ubuntu 7.4.0-1ubuntu1~18.04.1)
    configuration: --disable-debug --disable-doc --disable-ffplay --enable-shared --enable-avresample --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gpl --enable-libass --enable-fontconfig --enable-libfreetype --enable-libvidstab --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxcb --enable-libx265 --enable-libxvid --enable-libx264 --enable-nonfree --enable-openssl --enable-libfdk_aac --enable-postproc --enable-small --enable-version3 --enable-libbluray --extra-libs=-ldl --prefix=/opt/ffmpeg --enable-libopenjpeg --enable-libkvazaar --enable-libaom --extra-libs=-lpthread --enable-vaapi --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib
    libavutil      56. 31.100 / 56. 31.100
    libavcodec     58. 54.100 / 58. 54.100
    libavformat    58. 29.100 / 58. 29.100
    libavdevice    58.  8.100 / 58.  8.100
    libavfilter     7. 57.100 /  7. 57.100
    libavresample   4.  0.  0 /  4.  0.  0
    libswscale      5.  5.100 /  5.  5.100
    libswresample   3.  5.100 /  3.  5.100
    libpostproc    55.  5.100 / 55.  5.100
    Hardware acceleration methods:
    vaapi
    ```
    This is the above command's result for an `vaapi` image.

2.  Show the hardware accelerated encoders: `ffmpeg -encoders`
    ```
    $ ffmpeg -encoders | grep vaapi
    ffmpeg version 4.2.2 Copyright (c) 2000-2019 the FFmpeg developers
    built with gcc 7 (Ubuntu 7.4.0-1ubuntu1~18.04.1)
    configuration: --disable-debug --disable-doc --disable-ffplay --enable-shared --enable-avresample --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gpl --enable-libass --enable-fontconfig --enable-libfreetype --enable-libvidstab --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxcb --enable-libx265 --enable-libxvid --enable-libx264 --enable-nonfree --enable-openssl --enable-libfdk_aac --enable-postproc --enable-small --enable-version3 --enable-libbluray --extra-libs=-ldl --prefix=/opt/ffmpeg --enable-libopenjpeg --enable-libkvazaar --enable-libaom --extra-libs=-lpthread --enable-vaapi --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib
    libavutil      56. 31.100 / 56. 31.100
    libavcodec     58. 54.100 / 58. 54.100
    libavformat    58. 29.100 / 58. 29.100
    libavdevice    58.  8.100 / 58.  8.100
    libavfilter     7. 57.100 /  7. 57.100
    libavresample   4.  0.  0 /  4.  0.  0
    libswscale      5.  5.100 /  5.  5.100
    libswresample   3.  5.100 /  3.  5.100
    libpostproc    55.  5.100 / 55.  5.100
    V..... h264_vaapi            (codec h264)
    V..... hevc_vaapi            (codec hevc)
    V..... mjpeg_vaapi           (codec mjpeg)
    V..... mpeg2_vaapi           (codec mpeg2video)
    V..... vp8_vaapi             (codec vp8)
    V..... vp9_vaapi             (codec vp9)
    ```
    In the above example I grep only the VA-API enabled encoders for an `vaapi` image.

    3.  Show the hardware accelerated decoders: `ffmpeg -decoders`
    ```shell
    $ ffmpeg -decoders | grep vaapi
    ffmpeg version 4.2.2 Copyright (c) 2000-2019 the FFmpeg developers
    built with gcc 7 (Ubuntu 7.4.0-1ubuntu1~18.04.1)
    configuration: --disable-debug --disable-doc --disable-ffplay --enable-shared --enable-avresample --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gpl --enable-libass --enable-fontconfig --enable-libfreetype --enable-libvidstab --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxcb --enable-libx265 --enable-libxvid --enable-libx264 --enable-nonfree --enable-openssl --enable-libfdk_aac --enable-postproc --enable-small --enable-version3 --enable-libbluray --extra-libs=-ldl --prefix=/opt/ffmpeg --enable-libopenjpeg --enable-libkvazaar --enable-libaom --extra-libs=-lpthread --enable-vaapi --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib
    libavutil      56. 31.100 / 56. 31.100
    libavcodec     58. 54.100 / 58. 54.100
    libavformat    58. 29.100 / 58. 29.100
    libavdevice    58.  8.100 / 58.  8.100
    libavfilter     7. 57.100 /  7. 57.100
    libavresample   4.  0.  0 /  4.  0.  0
    libswscale      5.  5.100 /  5.  5.100
    libswresample   3.  5.100 /  3.  5.100
    libpostproc    55.  5.100 / 55.  5.100
    ```
    In the above example I grep only the VA-API enabled decoders for an `vaapi` image. Unfortunately VA-API does not support any hardware accelerated decoding.

> **Notice**:
> - Right now I know about encoding support for VA-API only.
> - NVIDIA CUDA and CUVID enable hardware acceleration for encoders, decoders and plugins like YOLOv3.

##  More details on FFmpeg hardware acceleration options

The [FFmpeg wiki: HWAccelIntro](https://trac.ffmpeg.org/wiki/HWAccelIntro) will give you many more details about hardware acceleration at all and the supported options depending on your drivers.