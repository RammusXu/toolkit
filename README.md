# My Toolkit [![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)](https://github.com/RammusXu/toolkit)
Feel free to open a issue to let me know if something wrong or outdated.

And sure, you can copy&paste to anywhere. But please add the reference just like I did.

## Links
- [Dockerhub](https://hub.docker.com/r/rammusxu/docker-box)

## LICENSE
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a><br />This project is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.

## Usage

### Gists
Execute
```bash
gist=https://raw.githubusercontent.com/RammusXu/toolkit/master/gist/install/github-action-runner.sh
curl -sL $gist | bash -
```

Download
```bash
gist=https://raw.githubusercontent.com/RammusXu/toolkit/master/gist/install/github-action-runner.sh
curl -sLO $gist
```

### Kubernetes resource
See what will generate
```bash
kustomize build github.com/RammusXu/toolkit/k8s/echoserver
```

Apply
```bash
kustomize build github.com/RammusXu/toolkit/k8s/echoserver | kubectl apply -f -
```

Clean
```bash
kustomize build github.com/RammusXu/toolkit/k8s/echoserver | kubectl delete -f -
```

## Start server
```
docker run -d --name toolkit -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```
