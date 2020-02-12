
```
#!/bin/bash
set -e

echo "Shell Start."
echo "=== Pythone Version ==="
python -V
echo "=== Install Docker ==="
sudo yum update -y -q
sudo yum -y -q install docker
echo "=== Start Docker ==="
sudo service docker start
sudo usermod -a -G docker ec2-user
echo "=== Docker Info ==="
sudo docker info
echo "=== OS Release ==="
cat /etc/os-release
echo "=== Test SSH ==="
ssh ec2-user@172.30.1.105 -o 'StrictHostKeyChecking=no' -o 'BatchMode=yes' -o 'ConnectionAttempts=1' true
echo "SSH Connect Success!"
echo "Shell Finish."
```