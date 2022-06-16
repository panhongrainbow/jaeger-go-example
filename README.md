# Jaeger Go Instrumentation Example
Two simple Go microservices where `service-a` calls `service-b`. Both services expose a `/ping` endpoint, instrumented with Jaeger+OpenTracing.

# Getting Started

## Start the example

Starts up the Jaeger all-in-one container, along with our example microservices.
```
$ make start
```

## Run the example

Hit `service-a`'s endpoint to trigger the trace.
```
$ curl -w '\n' http://localhost:8081/ping
```

## Validate

Should see `service-a -> service-b` on STDOUT.

Go to http://localhost:16686/ and select `service-a` from the "Service" dropdown and click the "Find Traces" button.

## Stop the example

Stop and remove containers.

```
$ make stop
```

# Podman support

## Installation

### Debian 11:

> - Consider to install a single package from `Debian sid` to get better `Podman` experiences.
> - Install stable Podman package first, then slightly upgrade Podman to the cutting edge version. It makes Debian more stable.

Install necessary `stable` packages by using `Apt` command

```bash
$ apt-get update

$ apt-get install podman buildah skopeo fuse-overlayfs slirp4netns golang-github-containers-buildah-dev golang-github-containers-common golang-github-containers-common-dev golang-github-containers-image golang-github-containers-image-dev golang-github-containers-libpod-dev golang-github-containers-ocicrypt-dev golang-github-containers-psgo-dev golang-github-containers-storage-dev golang-github-containernetworking-plugin-dnsname golang-github-containernetworking-plugins-dev crun

$ apt-get install libc6_2.33-7_amd64.deb libc6_2.33-7_i386.deb  podman-compose_1.0.3-2_all.deb
```

Check current Podman newest version

```bash
$ cat << EOF >> /etc/apt/sources.list
# unstable repo
deb http://deb.debian.org/debian unstable main contrib non-free
deb-src http://deb.debian.org/debian unstable main contrib non-free
EOF

$ apt-get update

$ apt search podman engine # newest vesion is 3.4.7
# podman/unstable 3.4.7+ds1-3+b1 amd64 [upgradable from: 3.0.1+dfsg1-3+deb11u1]
#   engine to run OCI-based containers in Pods
```

Gather newest Podman package

```bash
$ mkdir -p /var/lib/apt/podman/3.4.7
$ cd /var/lib/apt/podman/3.4.7/

$ apt-get --download-only --only-upgrade --no-install-recommends -o dir::cache=`pwd` install podman buildah skopeo fuse-overlayfs slirp4netns golang-github-containers-buildah-dev golang-github-containers-common golang-github-containers-common-dev golang-github-containers-image golang-github-containers-image-dev golang-github-containers-libpod-dev golang-github-containers-ocicrypt-dev golang-github-containers-psgo-dev golang-github-containers-storage-dev golang-github-containernetworking-plugin-dnsname golang-github-containernetworking-plugins-dev podman-compose crun

$ dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
```

Close unstable repository and add specific downloaded repository

```bash
$ vim /etc/apt/sources.list
# correct /etc/apt/sources.list in the following

# unstable repo
# deb http://deb.debian.org/debian/ unstable main
# deb-src http://deb.debian.org/debian/ unstable main

# Podman 3.4.7
deb [trusted=yes] file:/var/lib/apt/podman/3.4.7 ./
```

Upgrade Podman

```bash
$ apt-get update

$ apt-get --only-upgrade --no-install-recommends install podman buildah skopeo fuse-overlayfs slirp4netns golang-github-containers-buildah-dev golang-github-containers-common golang-github-containers-common-dev golang-github-containers-image golang-github-containers-image-dev golang-github-containers-libpod-dev golang-github-containers-ocicrypt-dev golang-github-containers-psgo-dev golang-github-containers-storage-dev golang-github-containernetworking-plugin-dnsname golang-github-containernetworking-plugins-dev podman-compose libc6
```

Check Podman

```bash
$ podman --log-level=debug info
# No error messages
```

Check Podman-compose

```bash
podman-compose --version
['podman', '--version', '']
using podman version: 3.4.7
podman-composer version  1.0.3
podman --version 
podman version 3.4.7
exit code: 0
```

## Rootless mode

> Refer to [Basic Setup and Use of Podman in a Rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md). set up the `rootless mode` step by step.

### Debian 11:

#### Check Podman information

debug information

```bash
$ podman --log-level=debug info

# rootless mode configurations are in following !
INFO[0000] podman filtering at log level debug          
DEBU[0000] Called info.PersistentPreRunE(podman --log-level=debug info) 
DEBU[0000] Merged system config "/usr/share/containers/containers.conf" 
DEBU[0000] Merged system config "/etc/containers/containers.conf" 
DEBU[0000] Using conmon: "/usr/bin/conmon"              
DEBU[0000] Initializing boltdb state at /var/lib/containers/storage/libpod/bolt_state.db 
DEBU[0000] Overriding tmp dir "/run/user/1001/libpod/tmp" with "/run/libpod" from database 
DEBU[0000] Using graph driver overlay                   
DEBU[0000] Using graph root /var/lib/containers/storage 
DEBU[0000] Using run root /run/containers/storage       
DEBU[0000] Using static dir /var/lib/containers/storage/libpod 
DEBU[0000] Using tmp dir /run/libpod                    
DEBU[0000] Using volume path /var/lib/containers/storage/volumes 
DEBU[0000] Set libpod namespace to ""                   
DEBU[0000] Not configuring container store              
DEBU[0000] Initializing event backend journald          
DEBU[0000] configured OCI runtime kata initialization failed: no valid executable found for OCI runtime kata: invalid argument 
DEBU[0000] configured OCI runtime runsc initialization failed: no valid executable found for OCI runtime runsc: invalid argument 
DEBU[0000] Using OCI runtime "/usr/bin/crun"            
INFO[0000] Found CNI network jaeger-go-example_default (type=bridge) at /home/panhong/.config/cni/net.d/jaeger-go-example_default.conflist 
DEBU[0000] Default CNI network name podman is unchangeable 
INFO[0000] Setting parallel job count to 25             
INFO[0000] podman filtering at log level debug          
DEBU[0000] Called info.PersistentPreRunE(podman --log-level=debug info) 
DEBU[0000] Merged system config "/usr/share/containers/containers.conf" 
DEBU[0000] Merged system config "/etc/containers/containers.conf" 
DEBU[0000] Using conmon: "/usr/bin/conmon"              
DEBU[0000] Initializing boltdb state at /var/lib/containers/storage/libpod/bolt_state.db 
DEBU[0000] Overriding tmp dir "/run/user/1001/libpod/tmp" with "/run/libpod" from database 
DEBU[0000] Using graph driver overlay                   
DEBU[0000] Using graph root /var/lib/containers/storage 
DEBU[0000] Using run root /run/containers/storage       
DEBU[0000] Using static dir /var/lib/containers/storage/libpod 
DEBU[0000] Using tmp dir /run/libpod                    
DEBU[0000] Using volume path /var/lib/containers/storage/volumes 
DEBU[0000] Set libpod namespace to ""                   
DEBU[0000] [graphdriver] trying provided driver "overlay" 
DEBU[0000] overlay: mount_program=/usr/bin/fuse-overlayfs 
DEBU[0000] backingFs=extfs, projectQuotaSupported=false, useNativeDiff=false, usingMetacopy=false 
DEBU[0000] Initializing event backend journald          
DEBU[0000] configured OCI runtime runsc initialization failed: no valid executable found for OCI runtime runsc: invalid argument 
DEBU[0000] configured OCI runtime kata initialization failed: no valid executable found for OCI runtime kata: invalid argument 
DEBU[0000] Using OCI runtime "/usr/bin/crun"            
INFO[0000] Found CNI network jaeger-go-example_default (type=bridge) at /home/panhong/.config/cni/net.d/jaeger-go-example_default.conflist 
DEBU[0000] Default CNI network name podman is unchangeable 
INFO[0000] Setting parallel job count to 25             
DEBU[0000] Loading registries configuration "/etc/containers/registries.conf" 
DEBU[0000] Loading registries configuration "/etc/containers/registries.conf.d/shortnames.conf" 

(...)

DEBU[0000] Called info.PersistentPostRunE(podman --log-level=debug info) 
```

plugin information

```yaml
host:
  arch: amd64
  buildahVersion: 1.23.1
  cgroupControllers:
  - cpuset
  - cpu
  - io
  - memory
  - pids
  cgroupManager: systemd
  cgroupVersion: v2
  conmon:
    package: 'conmon: /usr/bin/conmon'
    path: /usr/bin/conmon
    version: 'conmon version 2.0.25, commit: unknown'
  cpus: 8
  distribution:
    codename: bullseye
    distribution: debian
    version: "11"
  eventLogger: journald
  hostname: debian5
  idMappings:
    gidmap:
    - container_id: 0
      host_id: 1001
      size: 1
    - container_id: 1
      host_id: 165536
      size: 65536
    uidmap:
    - container_id: 0
      host_id: 1001
      size: 1
    - container_id: 1
      host_id: 165536
      size: 65536
  kernel: 5.10.0-15-amd64
  linkmode: dynamic
  logDriver: journald
  memFree: 15494119424
  memTotal: 33419116544
  ociRuntime:
    name: crun
    package: 'crun: /usr/bin/crun'
    path: /usr/bin/crun
    version: |-
      crun version 0.17
      commit: 0e9229ae34caaebcb86f1fde18de3acaf18c6d9a
      spec: 1.0.0
      +SYSTEMD +SELINUX +APPARMOR +CAP +SECCOMP +EBPF +YAJL
  os: linux
  remoteSocket:
    exists: true
    path: /run/user/1001/podman/podman.sock
  security:
    apparmorEnabled: false
    capabilities: CAP_CHOWN,CAP_DAC_OVERRIDE,CAP_FOWNER,CAP_FSETID,CAP_KILL,CAP_NET_BIND_SERVICE,CAP_SETFCAP,CAP_SETGID,CAP_SETPCAP,CAP_SETUID,CAP_SYS_CHROOT
    rootless: true
    seccompEnabled: true
    seccompProfilePath: /usr/share/containers/seccomp.json
    selinuxEnabled: false
  serviceIsRemote: false
  slirp4netns:
    executable: /usr/bin/slirp4netns
    package: 'slirp4netns: /usr/bin/slirp4netns'
    version: |-
      slirp4netns version 1.0.1
      commit: 6a7b16babc95b6a3056b33fb45b74a6f62262dd4
      libslirp: 4.4.0
  swapFree: 9999216640
  swapTotal: 9999216640
  uptime: 3h 19m 41.57s (Approximately 0.12 days)
plugins:
  log:
  - k8s-file
  - none
  - journald
  network:
  - bridge
  - macvlan
  volume:
  - local
registries: {}
store:
  configFile: /home/panhong/.config/containers/storage.conf
  containerStore:
    number: 5
    paused: 0
    running: 3
    stopped: 2
  graphDriverName: overlay
  graphOptions:
    overlay.mount_program:
      Executable: /usr/bin/fuse-overlayfs
      Package: 'fuse-overlayfs: /usr/bin/fuse-overlayfs'
      Version: |-
        fusermount3 version: 3.10.3
        fuse-overlayfs: version 1.8.2
        FUSE library version 3.10.3
        using FUSE kernel interface version 7.31
    overlay.mountopt: nodev
  graphRoot: /var/lib/containers/storage
  graphStatus:
    Backing Filesystem: extfs
    Native Overlay Diff: "false"
    Supports d_type: "true"
    Using metacopy: "false"
  imageStore:
    number: 22
  runRoot: /run/containers/storage
  volumePath: /var/lib/containers/storage/volumes
version:
  APIVersion: 3.4.7
  Built: 0
  BuiltTime: Thu Jan  1 08:00:00 1970
  GitCommit: ""
  GoVersion: go1.18.1
  OsArch: linux/amd64
  Version: 3.4.7
```

#### cgroup V2 support

`crun` is smaller, works faster than runc, and supports `cgroup v2`. Then cgroup v2 controls and limits resources to make podman `rootless mode`.





```bash
sudo sysctl kernel.unprivileged_userns_clone # set to 1
```



