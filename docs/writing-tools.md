---
title: 寫作工具
description: 整理一些常用的寫作工具，幫助個人學習或是解釋文章。
---

整理一些常用的寫作工具，幫助個人學習或是解釋文章。

- [xmind](https://xmind.works/): 心智圖 (Mind Map)。
- [hatchful](https://hatchful.shopify.com/): logo 產生器。
- [imagemagick](https://imagemagick.org/): 產生浮水印
  ```
  docker run --rm -it -v /Users/rammus/workspace/toolkit/docs/Today-I-Learned/img:/workdir avitase/docker-imagemagick:latest /bin/bash -c "
    composite -gravity east -dissolve 40 logo.png source.png out.jpg
  "
  ```
