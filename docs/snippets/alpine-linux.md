---
description: Alpine Linux examples, template, snippet
---

Alpine Linux examples, template, snippet

## Useful packages
```bash
apk add busybox-extra
apk add bind-tools
apk add curl httpie
```

### Build gcc
```bash
apk add build-base linux-headers
```
```
$ docker run -it --rm alpine:3.12 apk add build-base linux-headers
fetch http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.12/community/x86_64/APKINDEX.tar.gz
(1/22) Upgrading musl (1.1.24-r8 -> 1.1.24-r9)
(2/22) Installing libgcc (9.3.0-r2)
(3/22) Installing libstdc++ (9.3.0-r2)
(4/22) Installing binutils (2.34-r1)
(5/22) Installing libmagic (5.38-r0)
(6/22) Installing file (5.38-r0)
(7/22) Installing gmp (6.2.0-r0)
(8/22) Installing isl (0.18-r0)
(9/22) Installing libgomp (9.3.0-r2)
(10/22) Installing libatomic (9.3.0-r2)
(11/22) Installing libgphobos (9.3.0-r2)
(12/22) Installing mpfr4 (4.0.2-r4)
(13/22) Installing mpc1 (1.1.0-r1)
(14/22) Installing gcc (9.3.0-r2)
(15/22) Installing musl-dev (1.1.24-r9)
(16/22) Installing libc-dev (0.7.2-r3)
(17/22) Installing g++ (9.3.0-r2)
(18/22) Installing make (4.3-r0)
(19/22) Installing fortify-headers (1.1-r0)
(20/22) Installing patch (2.7.6-r6)
(21/22) Installing build-base (0.5-r2)
(22/22) Installing linux-headers (5.4.5-r1)
Executing busybox-1.31.1-r16.trigger
OK: 213 MiB in 35 packages
```
