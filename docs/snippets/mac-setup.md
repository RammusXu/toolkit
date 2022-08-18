# Mac Setup
## Tool
### brew
Install:
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install bash-completion

# Then add the following line to your ~/.bash_profile:
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
```
Must have:
```bash
brew install python3
brew install pyenv

brew upgrade

pyenv install 3.6.8
```

### Terminal
```
brew cask install iterm2
brew install zsh zsh-completions
```

`iTerm2 > Preferences > Profiles > Keys`

https://medium.com/@jonnyhaynes/jump-forwards-backwards-and-delete-a-word-in-iterm2-on-mac-os-43821511f0a

- ⌥+←
- ⌥+→
- escape

### zsh
https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
plugins=(git z httpie zsh-autosuggestions)

What I use:
- https://github.com/zsh-users/zsh-autosuggestions
- git z httpie

## Software
- source tree
- vs code
- docker for desktop
- [rectangle](https://rectangleapp.com/) - 螢幕排版
- [Xnip](https://www.xnipapp.com/) - 截圖軟體

## Setting
  - Touchpad
    - 點一下來選按
  - Sharing
    - Computer name
  - 輔助使用
    - Touchpad
      - touchpad option > 拖移 > 三指拖移
  - Keyboard
    - 按鍵重複 > 快
    - 重複前暫延 > 短
    - 使用 F1, F2
  - 指揮中心
    - 根據最近的使用情況重新排列空間 > uncheck
