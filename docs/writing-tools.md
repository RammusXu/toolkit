---
title: 寫作工具
description: 整理一些常用的寫作工具，幫助個人學習或是解釋文章。
---

整理一些常用的寫作工具，幫助個人學習或是解釋文章。

- [xmind](https://xmind.works/): 心智圖 (Mind Map)。
- [hatchful](https://hatchful.shopify.com/): logo 產生器。
- [imagemagick](https://imagemagick.org/): 產生浮水印。
  ```
  docker run --rm -it -v /Users/rammus/workspace/toolkit/docs/Today-I-Learned/img:/workdir avitase/docker-imagemagick:latest /bin/bash -c "
    composite -gravity east -dissolve 40 logo.png source.png out.jpg
  "
  ```

## 專案管理
- ~~[clockify](https://clockify.me): 管理時程、花費多少時間。~~(2021)
- [toggl](https://toggl.com): 管理時程、花費多少時間、有 chrome 插件、有 iOS app、可離線操作。
- [clickup](https://clickup.com): 專案管理、跟多種工具都可以整合、有 chrome 插件、time tracker
- [notion](https://www.notion.so/product): 專案管理工具
