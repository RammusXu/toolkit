## Install

sh -c "$(curl -fsLS git.io/chezmoi)"

雖然也可以用 `brew install chezmoi` 安裝，但是有可能是新的機器，或是 Linux 機器，為了一致性，所以都用 `curl` 安裝。

If you already have a dotfiles repo using chezmoi on GitHub at https://github.com/<github-username>/dotfiles then you can install chezmoi and your dotfiles with the single command:
```
sh -c "$(curl -fsLS git.io/chezmoi)" -- init --apply rammusxu
```


## Init

https://github.com/new

```
chezmoi init --apply rammusxu
```

## Update
```bash
chezmoi update
```


## Setting

https://www.chezmoi.io/docs/how-to/#use-chezmoi-on-macos
