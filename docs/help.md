---
description: Tips about writing in mkdocs.
---

# Help

Tips about writing in mkdocs.

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

## Highlight Code

````md
```yaml hl_lines="9 10 11 17"
kind: Service
apiVersion: v1
metadata:
  name: dnsmasq
spec:
  selector:
    name: dnsmasq
  type: LoadBalancer
  externalIPs:
  - a.a.a.a
  - a.a.a.b
  ports:
  - name: dnsmasq-udp
    port: 53
    protocol: UDP
    targetPort: dnsmasq-udp
  # loadBalancerIP: a.a.a.a
```
````

```yaml hl_lines="9 10 11 17"
kind: Service
apiVersion: v1
metadata:
  name: dnsmasq
spec:
  selector:
    name: dnsmasq
  type: LoadBalancer
  externalIPs:
  - a.a.a.a
  - a.a.a.b
  ports:
  - name: dnsmasq-udp
    port: 53
    protocol: UDP
    targetPort: dnsmasq-udp
  # loadBalancerIP: a.a.a.a
```

## Escape **```** in markdown

Wrap it by one more **`**
`````md
````
```yaml
kind: Service
apiVersion: v1
metadata:
  name: dnsmasq
```
````
`````

````md
```yaml
kind: Service
apiVersion: v1
metadata:
  name: dnsmasq
```
````

## Link(reference) to internal documents
```
[Writing in Visual Studio Code](snippets/visual-studio.md)
[Mac Setup](mac-setup.md)
[Help](../help.md)
```