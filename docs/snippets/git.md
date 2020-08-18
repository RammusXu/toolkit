---
description: Git examples, template, snippet
---

Git examples, template, snippet

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

# Get current commit sha
git rev-parse --short=7 HEAD
```


## Submodule
```
git submodule update --init
```

### Clean submodule
```bash
rm -rf .gitmodules

## .git/config
[submodule "themes/landscape"]

rm -rf .git/modules
```
