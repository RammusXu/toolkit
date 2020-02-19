# Help

- [mkdocs.org](https://www.mkdocs.org/)
- [mkdocs-material](https://squidfunk.github.io/mkdocs-material/)
    - [codehilite](https://squidfunk.github.io/mkdocs-material/extensions/codehilite/#usage)
    - [admonition - note block](https://squidfunk.github.io/mkdocs-material/extensions/admonition/#types)
    - [Pymdown](https://squidfunk.github.io/mkdocs-material/extensions/pymdown/#usage)
- [Writing in Visual Studio Code](snippets/visual-studio.md)


## Tabs

This need [pymdownx.superfences](https://squidfunk.github.io/mkdocs-material/extensions/pymdown/#installation)

```
    ``` bash tab=
    echo hi
    ```

    ``` py tab=
    print('hi')
    ```
```


``` bash tab=
echo hi
```

``` py tab=
print('hi')
```

## Hightlight
This need [pymdownx.mark](https://squidfunk.github.io/mkdocs-material/extensions/pymdown/#mark)
```
This is a ==highlight==.
```
This is a ==highlight==.

## Link(reference) to internal documents
```
[Writing in Visual Studio Code](snippets/visual-studio.md)
[Mac Setup](mac-setup.md)
[Help](../help.md)
```