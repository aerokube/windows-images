
https://www.microsoft.com/en-us/software-download/windows10ISO


$ ls
virtio-win-0.1.141.iso  Win10_1809Oct_English_x32.iso

$ qemu-img create -f qcow2 hdd.img 40G
Formatting 'hdd.img', fmt=qcow2 size=42949672960 cluster_size=65536 lazy_refcounts=off refcount_bits=16

$ sudo qemu-system-x86_64 -enable-kvm \
        -machine q35 -smp sockets=1,cores=1,threads=2 -m 2048 \
        -usb -device usb-kbd -device usb-tablet -rtc base=localtime \
        -net nic,model=virtio -net user,hostfwd=tcp::4444-:4444 \
        -drive file=hdd.img,media=disk,if=virtio \
        -drive file=Win10_1809Oct_English_x32.iso,media=cdrom \
        -drive file=virtio-win-0.1.141.iso,media=cdrom 

E:\viostor\w10\x86\viostor.inf

DISM.exe /Online /Add-Capability /CapabilityName:Microsoft.WebDriver~~~~0.0.1.0

Disable firewall

$ qemu-img create -b hdd.img -f qcow2 snapshot.img
Formatting 'snapshot.img', fmt=qcow2 size=42949672960 backing_file=hdd.img cluster_size=65536 lazy_refcounts=off refcount_bits=16

$ sudo qemu-system-x86_64 -enable-kvm \
        -machine q35 -smp sockets=1,cores=1,threads=2 -m 2048 \
        -usb -device usb-kbd -device usb-tablet -rtc base=localtime \
        -net nic,model=virtio -net user,hostfwd=tcp::4444-:4444 \
        -drive file=snapshot.img,media=disk,if=virtio \
        -monitor stdio

MicrosoftWebDriver.exe --host=10.0.2.15 --port=4444 --verbose

$ sudo qemu-system-x86_64 -enable-kvm \
        -machine q35 -smp sockets=1,cores=1,threads=2 -m 2048 \
        -usb -device usb-kbd -device usb-tablet -rtc base=localtime \
        -net nic,model=virtio -net user,hostfwd=tcp::4444-:4444 \
        -drive file=snapshot.img,media=disk,if=virtio \
        -loadvm windows

$ curl http://localhost:4444/session -d  '{"capabilities": {"alwaysMtch": {"browserName":"MicrosoftEdge"}}}'
{"value":{"sessionId":"6CC53217-C889-4045-A5B3-059F2C49FDE6","capabilities":{"acceptInsecureCerts":false,"browserName":"MicrosoftEdge","browserVersion":"44.17763.1.0","pageLoadStrategy":"normal","platformName":"windows","setWindowRect":false,"timeouts":{"implicit":0,"pageLoad":300000,"script":30000},"proxy":{}}}}

$ curl http://localhost:4444/session/6CC53217-C889-4045-A5B3-059F2C49FDE6/url -d  '{"url": "http://www.whatismybrowser.com/"}'

$ curl -X DELETE http://localhost:4444/session/6CC53217-C889-4045-A5B3-059F2C49FDE6

$ mv hdd.img snapshot.img image

$ docker build -t windows/edge:18 .

$ docker run -it --rm --privileged -p 4444:4444 -p 5900:5900 windows/edge:18

