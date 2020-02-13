install: 
	pip install -r requirements.txt
start: install
	mkdocs serve
