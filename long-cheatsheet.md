# Git
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

# Process
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

# System config
```
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
sysctl -w vm.max_map_count=262144

sysctl -a|grep vm
sysctl -a|grep vm.max_map_count
sysctl vm.max_map_count
```

# Disk

# Monitor
```
# Login log
last
lastlog
```

# Speed Test
```
curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Size: %{size_download} \n" https://google.com
```

# Linux User
```
/etc/ssh/sshd_config
/etc/passwd
/etc/sudoers
userdel ashish
userdel -r ashish # and Home Directory
```

# cp
```
# Copy folder content to another folder
cp -ar plugins/. share-plugins
```

# apt-get
```
# ping
apt-get install iputils-ping

# dig, nslookup
apt-get install dnsutils -y

# ps
apt-get install procps

# mysql
apt-get install mysql-client
```

# terraform
```
terraform state list
terraform state rm aws_lb.stage
```

# wget/ curl
```
wget -qO- your_link_here | tar xvz -
wget -qO- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -


wget -O- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz | tar xvz -C .

wget -O- https://github.com/sing1ee/elasticsearch-jieba-plugin/archive/v7.0.0.tar.gz| tar -xzv -C . --strip 1

wget -q -O tmp.zip http://downloads.wordpress.org/plugin/akismet.2.5.3.zip && unzip tmp.zip && rm tmp.zip


https://httpbin.org/
curl -X GET "https://httpbin.org/ip" -H "accept: application/json"
curl https://httpbin.org/ip
```