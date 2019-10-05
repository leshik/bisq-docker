# Bisq in Docker with noVNC

This is a set of files to make [Bisq](https://github.com/bisq-network/bisq) run in Docker **on the hardware you control**, including `Raspberry PI`, with the external `tor` and [noVNC](https://github.com/novnc/noVNC) for the remote access. **Don't use this on public cloud such as AWS!**

## Using

Clone this repo, then copy `.env.example` to `.env` and edit it according to your needs. The following environment variables are used:

* `USERNAME` and `PASSWORD` to authenticate your session in browser
* `TZ` – the timezone, e.g. `Europe/London` (optional)
* `JAVA_OPTS` – `JVM` options, e.g. `-Xms512M -Xmx512M` (optional)
* `BISQ_DESKTOP_OPTS` – `Bisq` command line arguments (optional)

The following volumes are created to store `tor` and `Bisq` data:

* `tor-etc` (mainly for `control_auth_cookie`)
* `tor-data` (stores `www` hidden service)
* `user-data` (all `Bisq` data)

Be sure to backup `tor-data` and `user-data` to preserve your `www` address and wallet.

Then you just launch it with `docker-compose up -d`. It binds to the `8080` port so that you may access it from your LAN. Don't expose this to the Internet, it's unenctypted!

The cool part, you can use e.g. `Private Window with Tor` in `Brave` browser, or similar to access it from anywhere! To make this work, get your `tor` address:

```
docker-compose exec tor cat /var/lib/tor/www/hostname
```

When using `tor`, the connection is encrypted, despite the `Not secure` badge in the browser. The `noVNC` complain regarding `unencrypted` connection concerns the link between `noVNC` and `tighVNC` which is inside Docker and moreover is only on `localhost` anyway.

### Raspberry Pi

There are several things that needs to be addressed to make `Bisq` work with acceptable speed on Raspberry Pi (assuming `RPi 3B+` or better):

* Use the external SSD. Really, SDXC is the main bottleneck, even with the best available cards. I/O just kills `Bisq` (maybe the controller is bad.) The most affordable option is [SanDisk Extreme Pro USB drive](https://www.sandisk.com/home/usb-flash/extremepro-usb) (which is, in fact, not USB flash drive, but SSD with USB interface.) `RPI 4` can't boot off USB yet, but at least you should put Docker volumes, or the whole `/var/lib/docker` on it.
* Use a good power supply AND a good cable (e.g. AWG 20.) Few people realize how bad the average USB power supplies & cables are. The pitfall here is that RPi provides very limited means to know if its CPU is throttling.
* Install the heatsink on RPi CPU (for the same reason.) Use [this script](https://github.com/bamarni/pi64/issues/4#issuecomment-292707581) to check if CPU is throttling or not.
* Use the minimal `Raspbian` image and change memory split in favor of main memory i.e. `16 MB` for video framebuffer.
* Comment the `CONF_SWAPSIZE` line in `/etc/dphys-swapfile` (assuming you already added SSD to your configuration.) Not necessary if you only store Docker volumes on SSD.
* Use `JAVA_OPTS` to limit Java heap size, i.e. `-Xms512M -Xmx512M`.
* Use `BISQ_DESKTOP_OPTS` to limit the number of network connections, i.e. `--maxConnections=6 --msgThrottlePerSec=40 --msgThrottlePer10Sec=200 --numConnectionForBtc=3`
* In case of `RPi 3B+`, use `Wi-Fi` as Ethernet sits on the same `USB 2.0` bus as your external SSD.

Be patient, initial sync takes a long time. While syncing, `Bisq` GUI becomes unresponsive on RPi. After the sync is complete, go to settings and disable `prevent standby` setting. It doesn't have much sense inside Docker, but generates unnecessary warnings about `Bisq` inability to access the audio device.
