## Process
```
ps aux | grep "java -jar build/libs/Hello-1.0.jar"
pgrep -f "java -jar build/libs/Hello-1.0.jar"
pkill -f "java -jar build/libs/Hello-1.0.jar"

pgrep -f "java -jar build/libs/Hello-1.0.jar" | xargs kill
pkill -f "java -jar build/libs/Hello-1.0.jar" || true

lsof -i :27017

ps aux | grep node
kill -9 PID
killall node
```

### Do something parallel

### 開多個 thread 同時執行多個指令
```bash
parallel docker push ::: \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_REF_TAG-builder \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_REF_TAG \
    $DOCKER_REGISTRY_URL/$DOCKER_REPOSITORY_NAME:$DOCKER_TAG
```

## System config
```
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
sysctl -w vm.max_map_count=262144

sysctl -a|grep vm
sysctl -a|grep vm.max_map_count
sysctl vm.max_map_count
```

## Disk, Storage
```bash
ls -lh file
du -sh folder
lsblk
```

### Generate random binary file
```bash
# 1 count = 512 Bytes
# of = output file name
dd if=/dev/urandom of=dd10 count=20
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

## cp
### Copy folder content to another folder
```bash
cp -ar plugins/. share-plugins
```

## apt-get
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

## wget, curl
```bash
# wget -qO- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -
wget -qO- your_link_here | tar xvz -

wget -O- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -C .

# wget -O- https://github.com/sing1ee/elasticsearch-jieba-plugin/archive/v7.0.0.tar.gz | tar -xzv -C . --strip 1
wget -O- your_link_here | tar -xzv -C . --strip 1
wget -c https://github.com/moby/buildkit/releases/download/v0.7.2/buildkit-v0.7.2.linux-amd64.tar.gz -O - | tar -xz


wget -q -O tmp.zip http://downloads.wordpress.org/plugin/akismet.2.5.3.zip && unzip tmp.zip && rm tmp.zip

curl -X GET "https://httpbin.org/ip" -H "accept: application/json"
curl https://httpbin.org/ip

curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
```

## httpie
```bash
## Print request infomations: header, payload
http localhost:3000 'Accept-Encoding: br, gzip, deflate' -v
## Print response header only
http localhost:3000 'Accept-Encoding: br, gzip, deflate' -h
```

### Get response time
```bash
curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Size: %{size_download} \n" https://google.com
curl -o /dev/null -s -w 'Total: %{time_total}s\n'  https://www.google.com
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
