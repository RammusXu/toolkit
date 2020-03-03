## Git
```
git branch -D 20190320_for_ssl
git branch -avv
git remote -v
git pull --rebase
git checkout -t origin/20190320_for_ssl
git checkout master
git push -u origin feature_branch_name
git push -u origin HEAD:20190401_add_k8s_stage

git remote prune origin --dry-run
git remote prune origin

git submodule update --init
```

## Process
```
ps aux | grep "java -jar build/libs/Hello-1.0.jar"
pgrep -f "java -jar build/libs/Hello-1.0.jar"
pkill -f "java -jar build/libs/Hello-1.0.jar"

echo $?
pgrep -f "java -jar build/libs/Hello-1.0.jar" | xargs kill
pkill -f "java -jar build/libs/Hello-1.0.jar" || true

lsof -i :27017

ps aux | grep node
kill -9 PID
killall node
```

### Do something parallel

開多個 thread 同時執行多個指令
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
```

## Monitoring
```bsah
# Login log
last
lastlog
```

### Keep tracking a command
```
watch -n 1 -d http http://localhost/
```

## Speed Test
```
curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Size: %{size_download} \n" https://google.com
```

## Linux User
```
/etc/ssh/sshd_config
/etc/passwd
/etc/sudoers
userdel ashish
userdel -r ashish # and Home Directory
```

## cp
```
# Copy folder content to another folder
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

wget -q -O tmp.zip http://downloads.wordpress.org/plugin/akismet.2.5.3.zip && unzip tmp.zip && rm tmp.zip

curl -X GET "https://httpbin.org/ip" -H "accept: application/json"
curl https://httpbin.org/ip

curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
```

## String(Text) Processing
```bash
# -P: Perl regex
# -o: Only match
# \K: Only match Perl regex will show
grep -oP 'foobar \K\w+' test.txt

# curl is wired. https://stackoverflow.com/questions/37014430/awk-how-to-concat-number-with-strings
# -P: multi process
# -I: input stream as a variable
xargs -P 10 -I username curl -sI https://xxxxxxxxxxx/username | grep 'Location: ' | awk '{print $2 "/a_string"}'

# -F: multi delimiter
awk -F' |\r' '{print $2 "/cover.jpg"}'
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