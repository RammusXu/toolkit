## Example

preparation: 
1. Download your service account json: `{ "type": "service_account", "project_id": ... }`
2. Encode json: `cat service_account.json | base64`
3. Setting -> Secrets -> Add: 
    - `GCLOUD_AUTH`: Encoded service account json.
```
name: gcloud-auth

on: ['pull_request']

jobs:
  test-docker-pull:
    runs-on: ubuntu-latest
    env:
      GCLOUD_AUTH: ${{ secrets.GCLOUD_AUTH }}
      GHR_USERNAME: ${{ secrets.GHR_USERNAME }}
      GHR_PASSWORD: ${{ secrets.GHR_PASSWORD }}
    steps:
    - uses: actions/checkout@v1
    - uses: ./actions/setup-auth
    - run: docker pull docker.pkg.github.com/swaglive/dockerfiles/sleep:alpine-3.8
    - run: docker pull asia.gcr.io/gcp_project-id/echo-box:2.0
```

## Release
```
npm run build
git add dist/index.js
git push
```