# Github Action
## On Trigger Event
```yaml

on:
  push:
    branches:
      - "master"
      - "**"
    tags:
      - "**"
  pull_request:
    branches:
      - master
  repository_dispatch:
    types: [rammus_post]
```

!!! important
    `pull_request.branches` is base on **ref**, not **head_ref**

## Starter
```yaml
on:
  push:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          echo hi
```

## Pass variables
```bash
echo ::set-output name=message::$output_message
echo ::set-env name=action_state::yellow
```

## Use variables
```yaml
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
PR_COMMENT_URL: ${{ github.event.pull_request.comments_url }}
PR_COMMENT: ${{ steps.message.outputs.message }}
```

## if condition
```yaml
if: contains(github.ref, 'tags')
if: steps.git-diff.outputs.is-diff
if: steps.set-env.outputs.message == 'hello'
if: github.event.action == 'rammus_post'
if: github.event_name == 'pull_request' && github.event.action == 'unassigned'
if: github.event_name == 'pull_request' && contains(github.head_ref, 'update-swag-bot')
```

## Setting
```yaml
ACTIONS_RUNNER_DEBUG: true
```

## Awesome Actions
Docker login 
```yaml
    - name: Docker Login - docker.pkg.github.com
      uses: swaglive/actions/docker/login@944b742
      with:
        password: ${{ secrets.GHR_PASSWORD }}
        username: ${{ secrets.GHR_USERNAME }}
        url: docker.pkg.github.com

    - name: Docker Login - docker.pkg.github.com
      if: contains(github.ref, 'tags')
      env: 
        DOCKER_PASSWORD: ${{ secrets.GITHUB_TOKEN }}
      run: echo $DOCKER_PASSWORD | docker login -u $GITHUB_ACTOR --password-stdin docker.pkg.github.com
    
```

Cache node_modules
```yaml
      - uses: actions/cache@v1
        with:
          path: ./node_modules
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-
```

Fetch private submodule
PAT = private access token
```yaml
    - name: Fix submodules
      run: echo -e '[url "https://github.com/"]\n  insteadOf = "git@github.com:"' >> ~/.gitconfig
    - name: Checkout
      uses: actions/checkout@v1
      with:
        fetch-depth: 0
        submodules: true
        token: ${{ secrets.PAT }}
```

Create pull request
```yaml
    - name: Create Pull Request
      if: steps.create-branch.outputs.branch_name
      uses: actions/github-script@0.3.0
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          github.pulls.create({
            owner: 'swaglive',
            repo: 'action-demo',
            title: '[Action] ${{ steps.create-branch.outputs.branch_name }}',
            head: '${{ steps.create-branch.outputs.branch_name }}',
            base: 'master'
          })
    - name: Create Pull Request
      if: steps.create-branch.outputs.branch_name
      uses: actions/github-script@0.3.0
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          github.pulls.create({
            ...context.repo,
            title: '[Action] ${{ steps.create-branch.outputs.branch_name }}',
            body: 'Create by `${{ github.event.client_payload.actor }}`',
            head: '${{ steps.create-branch.outputs.branch_name }}',
            base: 'master'
          })
```

Create a comment in pull request
```yaml
    - name: Notify Results in Pull Request
      if: steps.generate-mirror-list.outputs.images
      uses: actions/github-script@0.3.0
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        images: ${{ steps.generate-mirror-list.outputs.images }}
        script: |
          var body = "## I mirrored something for you"
          process.env.INPUT_IMAGES.split(' ').forEach(function(image){
            let [source, target] = image.split('@')
            body = `${body}\r\n- \`${source}\` -> \`${target}\``
          })

          github.issues.createComment({
            ...context.repo,
            issue_number: context.payload.number,
            body: body,
          })
```

## iOS App Build
- bitrise: 2 vCPU + 4 GB RAM
- Github Action: 2 vCPU + 7 GB RAM


## Test workflows
https://github.com/swaglive/action-demo/commit/4b0528f1fbfb125e98850f7ea9fb1d6ec32b46ac/checks?check_suite_id=382701123
```yaml
on: 
  repository_dispatch:

jobs:
  show-env:
    runs-on: ubuntu-latest
    steps:
    - run: cat $GITHUB_EVENT_PATH
    - run: echo ${{ github.event_name }}
    - run: echo ${{ github.event.action }}
    - run: env
```

```bash
## Ramms
INPUT_GITHUB_TOKEN=
INPUT_COMMENT_URL="https://api.github.com/repos/swaglive/action-demo/dispatches"

curl -H "Authorization: token $INPUT_GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    -d '{"event_type":"deploy_swag_bot","client_payload":{"new_version_image":"echo-server:96b2166", "new_version_sha":"96b2166","actor":"Rammus Xu"}}' \
    -XPOST $INPUT_COMMENT_URL

```

## Build status
```
[![](https://github.com/swaglive/swag-bot/workflows/release/badge.svg)](https://github.com/swaglive/swag-bot/tree/master)
```


## Reference
- https://github.com/actions/toolkit/tree/master/packages/github
- https://github.com/actions/github-script
- https://octokit.github.io/rest.js/#usage
