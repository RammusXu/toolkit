# Bash

### Date
```bash
DATE=$(date +%Y%m%d_%H%M%S)
FILE="/backup/backup-$DATE"
```

### Varaible
#### 設定/刪除
```bash
export A_VARIBALE
unset A_VARIBALE
```

#### 使用預設值
```
ACTOR=${ACTOR:-$GITHUB_ACTOR}
```

```bash
qq=ops:default
echo ${qq#*:}
# default
echo ${qq%:*}
# ops
```

### Generate High CPU Usage
```bash
while true; do echo "hi" ; done;
watch -n 1 -d http http://localhost/
```

### 暫時進到某個 folder 執行指令，不改變目前 path
```bash
(cd src/ && git checkout $NEW_VERSION_SHA) 
```

### ANSI - 輸出文字變色

https://misc.flogisoft.com/bash/tip_colors_and_formatting
```bash
echo -e "Default \e[31mRed"
echo -e "\e[31mHello\e[0m World"
echo -e "\e[1;31mHello\e[0m World"
```
`-e`: to use `\e[31m`

## Reference
- https://devhints.io/bash