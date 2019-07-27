# Bisq in Docker with VNC

## Building

Put the `desktop-X.X.X-all.jar` in the root folder, then:

```
docker build -t bisq:X.X.X .
```

## Using

Volume should be mounted to keep the wallet and other settings. The `VNC` port used is `5901`. The `VNC` password can be set using `VNCPASSWD` environment variable (default is `bisq`.)

```
docker run -d -p 5901:5901 -v $PWD/Bisq:/home/bisq/.local/share/Bisq -e VNCPASSWD=password --name bisq bisq:X.X.X
```
