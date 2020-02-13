

## 使用另一個 target
```
start:
	echo this is start
use-start:
	echo this is use-start
	$(MAKE) start
```

## target 依賴另一個 target
```
install: 
	pip install -r requirements.txt
start: install
	mkdocs serve
```

## Reference
- https://devhints.io/makefile