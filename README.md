# Bisq in Docker with VNC

## Building

### Introduction

The build process is split in two stages:

1. Compiling `Bisq` and extracting its `jar` binaries into the empty `Docker` image;
1. Building the self contained image with `JRE` and required libraries and `VNC`.

The reason behind this is the need to build `ARM` images. As `Bisq` is `Java` software, there is no need to rebuild `jar` files on each platform.

> `Docker Desktop` multiarch `--platform` flag doesn't work as expected yet. `ARM` images built using this flag have issues, apparently, due to `QEMU` compatibility. Don't use it for now.

### Requirements

[BuildKit](https://docs.docker.com/engine/reference/builder/#buildkit) is used to detect the platform (`TARGETPLATFORM` variable), thus:

1. `Docker` version `19.03` or later (due to `BuildKit` integration);
1. `Docker` experimental features enabled (to reduce images size with `--squash` flag.)

The latter can be achieved by adding the following configuration to `/etc/docker/daemon.json`:

```
{
  "experimental" : true
}

```

### Building `Bisq` binaries

This step should be done on the performant machine, such as PC or Mac. The resulting image can be exported with `docker save` and then transferred to e.g. Raspberry Pi to import with `docker load` if needed.

```
DOCKER_BUILDKIT=1 docker build -t bisq:binaries -f Dockerfile.build .
```

> `ARM` support requires some patches to `Bisq`. Until these are upstreamed, pass `REPOSITORY` and `TAG` arguments using the `--build-arg` [flag](https://docs.docker.com/engine/reference/builder/#arg). See available tags [here](https://github.com/leshik/bisq/tags).

### Building the platform image

Assuming `bisq:binaries` image is already there:

```
DOCKER_BUILDKIT=1 docker build -t bisq --squash .
```

The `--squash` flag is optional, however it reduces the size of the resulting image as some unneded binaries are deleted during build (i.e. `javafx` libs which are already present in the image and `tor` binaries which aren't specific to the current platform.)

## Using

Prebuilt images for `amd64`, `armhf` and `arm64` are available [here](https://hub.docker.com/r/leshik/bisq).

The volume should be mounted to keep the wallet and other settings. The `VNC` port is `5901`, the default password is `bisq`. Environment variables that can be set are:

* `VNCPASSWD` – the `VNC` password
* `TZ` – the timezone, e.g. `Europe/London`
* `JAVA_OPTS` – `JVM` options, e.g. `-Xms256M -Xmx512M`
* `BISQ_DESKTOP_OPTS` – `Bisq` command line arguments

Example:

```
docker run -d -p 5901:5901 -v $PWD/Bisq:/home/bisq/.local/share/Bisq -e VNCPASSWD=password -e TZ='Europe/London' --name bisq leshik/bisq:X.X.X
```

### Raspberry Pi

There are several things that needs to be addressed to make `Bisq` work with acceptable speed on Raspberry Pi (assuming `RPi 3B+` or better):

* Use external SSD. Really, SDXC is the main bottleneck, even with the best available cards. I/O just kills `Bisq` (maybe the controller is bad.) The most affordable option is [SanDisk Extreme Pro USB drive](https://www.sandisk.com/home/usb-flash/extremepro-usb) (which is, in fact, not USB flash drive, but SSD with USB interface.)
* Use a good power supply AND a good cable (e.g. AWG 20.) Few people realize how bad the average USB power supplies & cables are. The pitfall here is that RPi provides very limited means to know if its CPU is throttling.
* Install the heatsink on RPi CPU (for the same reason.) Use [this script](https://github.com/bamarni/pi64/issues/4#issuecomment-292707581) to check if CPU is throttling or not.
* Use the minimal `Raspbian` image and change memory split in favor of main memory i.e. `16 MB` for video framebuffer.
* Comment the `CONF_SWAPSIZE` line in `/etc/dphys-swapfile` (assuming you already added SSD to your configuration.)
* Use `JAVA_OPTS` to limit Java heap size, i.e. `-Xms256M -Xmx512M`.
* Use `BISQ_DESKTOP_OPTS` to limit the number of network connections, i.e. `--maxConnections=6 --msgThrottlePerSec=40 --msgThrottlePer10Sec=200 --numConnectionForBtc=3`
* In case of `RPi 3B+`, use `Wi-Fi` as Ethernet sits on the same `USB 2.0` bus as your external SSD.

Be patient, initial sync takes a long time. While syncing, `Bisq` GUI becomes unresponsive on RPi. After the sync is complete, go to settings and disable `prevent standby` setting. It doesn't have much sense inside Docker, but generates unnecessary warnings about `Bisq` inability to access the audio device.
