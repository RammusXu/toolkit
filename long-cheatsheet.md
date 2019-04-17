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

# apt-get
```
apt-get install iputils-ping
apt-get install mysql-client
```

# terraform
```
terraform state list
terraform state rm aws_lb.stage
```