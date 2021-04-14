---
description: 常用的 linux 指令集與範例
---

# Linux commands

常用的 linux 指令集與範例

## Table of Contents

- Process:
    - [ps](#ps) - 目前的所有 process。
    - [lsof](#lsof) - 列出 open files。
    - [screen](#screen) - 在背景執行程序。
- Linux Kernel:
    - [sysctl](#sysctl) - 修改 Linux Kernel 參數。
- Disk, File system:
    - [ls](#ls) - 列出資料夾內容。
    - [du](#du) - 計算檔案使用空間。
    - [lsblk](#lsblk) - 列出 block devices。
    - [dd](#dd) - 轉換、複製、產生檔案。
    - [tail](#tail) - 印出檔案的最後幾行。
    - [untar](#untar) - 壓縮、解壓縮檔案。
    - [fio](#fio) - disk i/o 壓力測試。
- Network:
    - [wget](#wget) - 下載網路資源。
    - [curl](#curl) - 下載網路資源。
    - [httpie](#httpie) - 下載網路資源。RESTful like CLI。
    - [netstat](#netstat)
- Miscellaneous:
    - [parallel](#parallel) - 並行執行指令。

## Process
### ps
```
ps aux | grep "java -jar build/libs/Hello-1.0.jar"
pgrep -f "java -jar build/libs/Hello-1.0.jar"
pkill -f "java -jar build/libs/Hello-1.0.jar"

pgrep -f "java -jar build/libs/Hello-1.0.jar" | xargs kill
pkill -f "java -jar build/libs/Hello-1.0.jar" || true


ps aux | grep node
kill -9 PID
killall node
```

### lsof
列出佔用中的 port
```bash
# lsof -i -P -n | grep LISTEN
systemd-r   645 systemd-resolve   13u  IPv4  16633      0t0  TCP 127.0.0.53:53 (LISTEN)
sshd        882            root    3u  IPv4  19952      0t0  TCP *:22 (LISTEN)
sshd        882            root    4u  IPv6  19969      0t0  TCP *:22 (LISTEN)
```

確定 port 有沒有被佔用
```
lsof -i :22
```

### screen
在背景執行程序。

```bash
screen
screen -ls
screen -r 69262.ttys001.mac-mini
```

熱鍵

```
ctrl+a d Detach 現在的 screen
```

## Linux Kernel
### sysctl
參數會在 `/proc/sys` 資料夾下。
```
sysctl vm.max_map_count
sysctl -w vm.max_map_count=262144
sysctl -a | grep vm
sysctl -a | grep vm.max_map_count
```

## Disk, Storage
### ls
```bash
ls -lh file
```
### du
```bash
du -sh .
```
### lsblk
```bash
lsblk
lsblk -a
```
### dd
Generate random binary file
```bash
# 1 count = 512 Bytes
# of = output file name
dd if=/dev/urandom of=dd10 count=20
```

### tail
印出檔案的最後幾行

`tail -f buxybox-1` 會跟隨原始檔案
```bash
# tail -f busybox-1
hi
hi3

# echo hi >> busybox-1
# mv busybox-1 busybox-2
# echo hi2 >> busybox-1
# echo hi3 >> busybox-2
```

`tail -F buxybox-1` 會重複嘗試同一個檔案

```bash
# tail -F busybox-1
hi
tail: busybox-1 has become inaccessible: No such file or directory
tail: busybox-1 has appeared; following end of new file
hi

# echo hi >> busybox-1
# mv busybox-1 busybox-3
# echo hi >> busybox-1
```

### untar
壓縮、解壓縮檔案。
```bash
wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.33.tar.gz
tar -xf v0.33.tar.gz
# .
# ├── headers-more-nginx-module-0.33
# │   ├── README.markdown
# │   ├── config
# │   ├── src
# │   ├── t
# │   ├── util
# │   └── valgrind.suppress
# └── v0.33.tar.gz
```

## Monitoring
### Login log
```bash
last
lastlog
```

### Keep tracking a command
```
watch -n 1 -d http http://localhost/
```

## Linux User
```
/etc/ssh/sshd_config
/etc/passwd
/etc/sudoers
userdel ashish
userdel -r ashish # and Home Directory
```

### Linux - adduser without prompts
```bash
adduser runner --disabled-password  --gecos ""
```

### Linux - Add sudoer group to user
```bash
echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
usermod -aG sudo runner
```

### cp
Copy folder content to another folder
```bash
cp -ar plugins/. share-plugins
```

### apt-get
```bash
# ping
apt-get install iputils-ping

# dig, nslookup
apt-get install dnsutils -y

# ps
apt-get install procps

# mysql
apt-get install mysql-client
```
## Network
### wget
```bash
# wget -qO- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -
wget -qO- your_link_here | tar xvz -

wget -O- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -C .

# wget -O- https://github.com/sing1ee/elasticsearch-jieba-plugin/archive/v7.0.0.tar.gz | tar -xzv -C . --strip 1
wget -O- your_link_here | tar -xzv -C . --strip 1
wget -c https://github.com/moby/buildkit/releases/download/v0.7.2/buildkit-v0.7.2.linux-amd64.tar.gz -O - | tar -xz


wget -q -O tmp.zip http://downloads.wordpress.org/plugin/akismet.2.5.3.zip && unzip tmp.zip && rm tmp.zip
```
### curl
```
curl -X GET "https://httpbin.org/ip" -H "accept: application/json"
curl https://httpbin.org/ip

curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
```

### Get response time
```bash
TARGET=google.com
curl -s -o /dev/null -w "target=${TARGET} time_namelookup=%{time_namelookup} time_connect=%{time_connect} time_appconnect=%{time_appconnect} time_starttransfer=%{time_starttransfer} time_total=%{time_total} size_download=%{size_download} speed_download=%{speed_download} remote_ip=%{remote_ip}\n" "${TARGET}"

curl -o /dev/null -s -w 'Total: %{time_total}s\n'  https://www.google.com
```

![](https://blog.cloudflare.com/content/images/2018/10/Screen-Shot-2018-10-16-at-14.51.29-1.png)

### httpie
```bash
## Print request infomations: header, payload
http localhost:3000 'Accept-Encoding: br, gzip, deflate' -v
## Print response header only
http localhost:3000 'Accept-Encoding: br, gzip, deflate' -h
```

### netstat
Show ports in use
```
netstat -plnt
```

### nc
```bash
## Check if a port is opened
/workspace # nc -vz localhost 3000
localhost (127.0.0.1:3000) open
```

## String(Text) Processing
```bash
# -P: Perl regex
# -o: Only match
# \K: Only match Perl regex will show
grep -oP 'foobar \K\w+' test.txt
# -F: multi delimiter
awk -F' |\r' '{print $2 "/cover.jpg"}'
```

### Using variable in xargs
```bash
# curl is wired. https://stackoverflow.com/questions/37014430/awk-how-to-concat-number-with-strings
# -P: multi process
# -I: input stream as a variable
xargs -P 10 -I username curl -sI https://xxxxxxxxxxx/username | grep 'Location: ' | awk '{print $2 "/a_string"}'
```

### Get nth line of stdout on linux
ref: https://stackoverflow.com/questions/1429556/command-to-get-nth-line-of-stdout
```bash
ls -l | sed -n 2p
ls -l | head -2 | tail -1
```

### Parsing xml in bash
```
apk add libxml2-utils curl
curl -s https://data.iana.org/root-anchors/root-anchors.xml | xmllint --format --xpath 'TrustAnchor/KeyDigest/KeyTag' -
```

## Load Testing
### Generate High CPU Usage
```bash
while true; do echo "hi" ; done;
while true; do curl localhost ; done;
```

### Generate High memory usage
ref: https://stackoverflow.com/questions/20200982/how-to-generate-a-memory-shortage-using-bash-script

```bash
yes | tr \\n x | head -c $BYTES | grep n
yes | tr \\n x | head -c 100m | grep n
```

## jq
```
$(msg=$(cat $(grep -E "(mirror to|replace by)" *.txt -l)) jq -nc '{"body":env.msg}')
```

## Miscellaneous
### parallel
開多個 thread 同時執行多個指令
```bash
parallel docker push ::: \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_REF_TAG-builder \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_REF_TAG \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_TAG
```
