#!/bin/sh

#!/bin/bash
SCREEN_RESOLUTION=${SCREEN_RESOLUTION:-"1024x768x24"}
ENABLE_WINDOW_MANAGER=${ENABLE_WINDOW_MANAGER:-""}
DISPLAY_NUM=99
export DISPLAY=":$DISPLAY_NUM"

VERBOSE=${VERBOSE:-""}
if [ -n "$VERBOSE" ]; then
    sed -i 's|@@DRIVER_ARGS@@|, "--log", "debug"|g' /etc/selenoid/browsers.json
fi

clean() {
  if [ -n "$XVFB_PID" ]; then
    kill -TERM "$XVFB_PID"
  fi
  if [ -n "$X11VNC_PID" ]; then
    kill -TERM "$X11VNC_PID"
  fi
}

trap clean INT TERM

xvfb-run -l -n $DISPLAY_NUM -s "-ac -screen 0 $SCREEN_RESOLUTION -noreset -listen tcp" \
	qemu-system-x86_64 -enable-kvm \
        -machine q35 -smp sockets=1,cores=1,threads=2 -m 2048 \
        -usb -device usb-kbd -device usb-tablet -rtc base=localtime \
        -net nic,model=virtio -net user,hostfwd=tcp::4444-:4444 \
        -drive file=snapshot.img,media=disk,if=virtio \
        -loadvm windows &

XVFB_PID=$!

retcode=1
until [ $retcode -eq 0 ]; do
  xdpyinfo -display $DISPLAY >/dev/null 2>&1
  retcode=$?
  if [ $retcode -ne 0 ]; then
    echo Waiting xvfb...
    sleep 1
  fi
done

x11vnc -display $DISPLAY -passwd aerokube -shared -forever -loop500 -rfbport 5900 -rfbportv6 5900 -logfile /dev/null &
X11VNC_PID=$!

wait

