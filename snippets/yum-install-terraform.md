https://www.terraform.io/downloads.html
右鍵複製連結 -> 取得 https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip

```
sudo yum update
sudo yum install -y wget
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64
sudo mv terraform /usr/local/bin/
```