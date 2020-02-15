---
description: Github Actions(CI/CD) tricks that official documents didn't mention. This post including hints, tips, snippet, cheatsheet, troubleshooting, notes, how-to.
---

# Github Action

Github Actions(CI/CD) tricks that official documents didn't mention. This post including hints, tips, snippet, cheatsheet, troubleshooting, notes, how-to.

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

## Environments and variables
### Pass variables
```bash
echo ::set-output name=message::$output_message
echo ::set-env name=action_state::yellow
```
### Use variables
```yaml
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
PR_COMMENT_URL: ${{ github.event.pull_request.comments_url }}
PR_COMMENT: ${{ steps.message.outputs.message }}
PAYLOAD_ACTOR: ${{ github.event.client_payload.actor }}
```

#### Get commit author information
This is only for ==push== event
```yaml
AUTHOR_NAME: ${{ github.event.head_commit.author.name }}
AUTHOR_EMAIL: ${{ github.event.head_commit.author.email }}
```

## if condition
```yaml
if: contains(github.ref, 'tags')
if: steps.git-diff.outputs.is-diff
if: steps.set-env.outputs.message == 'hello'
```

### pull_request
#### when specific event type
```yaml
if: github.event_name == 'pull_request' && github.event.action == 'unassigned'
```
#### when branch name is
```yaml
if: github.event_name == 'pull_request' && contains(github.head_ref, 'my-feature-branch')
```
#### when merged
```yaml
on: 
  pull_request:
    types: [closed]
jobs:
  merged:    
    if: github.event.pull_request.merged == true
```

## Setting
```yaml
ACTIONS_RUNNER_DEBUG: true
```

## Awesome Actions

### Customize action type with http post method
```yaml
on: 
  repository_dispatch:
    types: [rammus_post]
jobs:
  rammus_job:
    env:
      ACTOR: ${{ github.event.client_payload.actor }}
    if: github.event.action == 'rammus_post'
```

And you can send a post request like:

```bash
INPUT_GITHUB_TOKEN=
INPUT_COMMENT_URL="https://api.github.com/repos/<owner>/<repo>/dispatches"

curl -H "Authorization: token $INPUT_GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    -d '{"event_type":"rammus_post","client_payload":{"new_version_image":"echo-server:96b2166", "new_version_sha":"96b2166","actor":"Rammus Xu"}}' \
    -XPOST $INPUT_COMMENT_URL
```

### Docker login 
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

### Docker login and copy config to default container's workspace

!!! note
    github runner will mount `/home/runner/work/_temp/_github_home":"/github/home` when we use a docker action.
    That means we can't use the credential directly in next steps. Only if you use a docker contain step. Since `id: generate-mirror-list` need docker credentials and run on default container, credentials should be copied to default container's home.

    And a docker action must run as root. Therefore, it needs to be `sudo` in a default container.

```yaml
    - name: Docker Login - docker.pkg.github.com
      uses: swaglive/actions/docker/login@944b742
      with:
        password: ${{ secrets.GHR_PASSWORD }}
        username: ${{ secrets.GHR_USERNAME }}
        url: docker.pkg.github.com

    - name: Do something in default container's workspace
      run: |
        sudo cp -R /home/runner/work/_temp/_github_home/.docker ~
        sudo chown -R $(whoami) ~/.docker
        docker pull docker.pkg.github.com/swaglive/dockerfiles/kubectl:1.17
```

### Cache node_modules
```yaml
      - uses: actions/cache@v1
        with:
          path: ./node_modules
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-
```

### Fetch private submodule
PAT = [private access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)
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

### Create pull request
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

### Create a comment in pull request
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

### Get environments in action
```yaml
jobs:
  show-env:
    runs-on: ubuntu-latest
    steps:
    - run: cat $GITHUB_EVENT_PATH
    - run: echo ${{ github.event_name }}
    - run: echo ${{ github.event.action }}
    - run: env
```

## Othes
### iOS App Build
Compare:

- bitrise: 2 vCPU + 4 GB RAM
- Github Action: 2 vCPU + 7 GB RAM

### Build status
```yaml tab="Clickable"
[![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)](https://github.com/RammusXu/toolkit)
```

```yaml tab="Unclickable"
![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)
```

- Clickable: [![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)](https://github.com/RammusXu/toolkit)
- Unclickable: ![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)

## Reference
- https://help.github.com/en/actions/reference
- https://github.com/actions/toolkit/tree/master/packages/github
- https://github.com/actions/github-script
- https://octokit.github.io/rest.js/#usage
