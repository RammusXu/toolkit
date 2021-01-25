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

## On trigger event
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
echo "action_state=yellow" >> $GITHUB_ENV

# Deprecated. ref: https://github.blog/changelog/2020-10-01-github-actions-deprecating-set-env-and-add-path-commands/
echo ::set-env name=action_state::yellow
```

### Use variables
```yaml
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
GITHUB_TOKEN: ${{ env.ACTION_STATE }}
PR_COMMENT: ${{ steps.message.outputs.message }}
PR_COMMENT_URL: ${{ github.event.pull_request.comments_url }}
PAYLOAD_ACTOR: ${{ github.event.client_payload.actor }}
```

### Use GITHUB_ACTOR as git commit author and using github avator
https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
```yaml
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
remote_repo="https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${GITHUB_REPOSITORY}.git"
git remote add origin "${remote_repo}"
```

#### Get commit author information
This is only for ==push== event
```yaml
AUTHOR_NAME: ${{ github.event.head_commit.author.name }}
AUTHOR_EMAIL: ${{ github.event.head_commit.author.email }}
```

### Customize docker action
```yaml
name: 'Update Status'
description: 'Update status'
inputs:
  state:
    description: 'Option: success, failure'
    required: false
    default: 'success'
  auth_token:
    description: 'Auth token used to API'
    required: true
    default: "${{ github.token }}"
  pull_sha:
    description: 'Commit SHA'
    default: "${{ github.event.pull_request.head.sha}}"
    required: false
  push_sha:
    description: 'Commit SHA'
    required: false
    default: "${{ github.sha }}"
```

```bash
if [[ $GITHUB_EVENT_NAME == 'pull_request' ]]; then
    COMMIT_SHA=$INPUT_PULL_SHA
else
    COMMIT_SHA=$INPUT_PUSH_SHA
```


## if condition
```yaml
if: contains(github.ref, 'refs/tags')
if: contains(github.event.issue.title, 'Update APK')
if: steps.git-diff.outputs.is-diff
if: steps.set-env.outputs.message == 'hello'
if: github.ref != 'refs/heads/master'
if: github.event.action == 'dispatch_rammus_customize_action_type'
if: github.event.issue.pull_request
if: github.event_name == 'pull_request' && contains(github.head_ref, 'update-app')
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

## Job syntax
### Wait other jobs finish
```
jobs:
  job1:
  job2:
    needs: job1
  job3:
    needs: [job1, job2]
```

## Setting
```yaml
ACTIONS_RUNNER_DEBUG: true
```

## Build an action

### Docker Action Example
```yaml
# action.yml
name: 'Hello World'
description: 'Greet someone and record the time'
inputs:
  who-to-greet:  # id of input
    description: 'Who to greet'
    required: true
    default: 'World'
outputs:
  time: # id of output
    description: 'The time we greeted you'
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - ${{ inputs.who-to-greet }}
```
### Composite (Multiple steps) Action Example
```yaml
name: 'Hello World'
description: 'Greet someone'
inputs:
  who-to-greet:  # id of input
    description: 'Who to greet'
    required: true
    default: 'World'
outputs:
  random-number:
    description: "Random number"
    value: ${{ steps.random-number-generator.outputs.random-id }}
runs:
  using: "composite"
  steps:
    - run: echo Hello ${{ inputs.who-to-greet }}.
      shell: bash
    - id: random-number-generator
      run: echo "::set-output name=random-id::$(echo $RANDOM)"
      shell: bash
    - run: ${{ github.action_path }}/goodbye.sh
      shell: bash
```

### Get input as environemnt in Docker
```yaml
# action.yaml
inputs:
  who-to-greet:
```
```yaml
# workflow.yaml
      - uses: ./actions/my-action
        with:
          who-to-greet: rammus
```

```bash
# entrypoint.sh
echo INPUTS_WHO_TO_GREET
```

### ENTRYPOINT need to be abolute path

!!! warning
    When `uses: ./actions/my-action`
    Workflow will mount workspace `--workdir /github/workspace`

```bash
COPY ./app.py /
ENTRYPOINT python /app.py
```

## Awesome Actions

### Manually/Customize trigger a workflow

https://github.blog/changelog/2020-07-06-github-actions-manual-triggers-with-workflow_dispatch/
```yaml
on:
  workflow_dispatch:
    inputs:
      logLevel:
        description: 'Log level'
        required: true
        default: 'warning'
      tags:
        description: 'Test scenario tags'

jobs:
  printInputs:
    runs-on: ubuntu-latest
    steps:
    - run: |
        echo "Log level: ${{ github.event.inputs.logLevel }}"
        echo "Tags: ${{ github.event.inputs.tags }}"
```

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

### Docekr build and push to ghcr.io when pushing a git tag
```yaml
name: Tag

on:
  push:
    tags:
      - "**"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set Env
        run: |
          echo "BUILD_TAG=${GITHUB_REF/refs\/tags\//}" >> $GITHUB_ENV
          echo "BUILD_SHA=${GITHUB_SHA:0:7}" >> $GITHUB_ENV

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Docker Login
        # uses: docker/login-action@f3364599c6aa293cdc2b8391b1b56d0c30e45c8a
        uses: docker/login-action@v1.8.0
        with:
          registry: ghcr.io
          username: ${{ secrets.GHCR_USERNAME }}
          password: ${{ secrets.GHCR_PASSWORD }}

      - name: Build and push Docker images
        # uses: docker/build-push-action@4a531fa5a603bab87dfa56578bd82b28508c9547
        uses: docker/build-push-action@v2.2.2
        with:
          context: "."
          tags: |
            ghcr.io/${{ github.repository }}:${{ env.BUILD_TAG }}
            ghcr.io/${{ github.repository }}:${{ env.BUILD_SHA }}
          push: true
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
    - name: Get yarn cache directory path
      id: yarn-cache-dir-path
      run: echo "::set-output name=dir::$(yarn cache dir)"
    - uses: actions/cache@v2
      with:
        path: ${{ steps.yarn-cache-dir-path.outputs.dir }}
        key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
        restore-keys: |
          ${{ runner.os }}-yarn-
```

### Fetch private submodule
PAT = [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)

`actions/checkout@v2` fixed `git@github.com` problem
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
      with:
        fetch-depth: 0
        submodules: true
        token: ${{ secrets.PAT }}
```

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
      uses: actions/github-script@v3
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
      uses: actions/github-script@v3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          github.pulls.create({
            ...context.repo,
            title: '[Action] ${{ steps.create-branch.outputs.branch_name }}',
            body: `Created by \`${ process.env.GITHUB_ACTOR }\``,
            head: '${{ steps.create-branch.outputs.branch_name }}',
            base: 'master'
          })
```

### Commit and push and create pull request
```yaml
    - name: Set environments
      run: echo "NEW_BRANCH=update-config-$(date +%Y-%m-%d_%H%M%S-utc)" >> $GITHUB_ENV
    - name: Configure git
      run: |
        git config --global user.name "${GITHUB_ACTOR}"
        git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
    - name: Commit
      run: git commit -a -m "Update config.json by ${GITHUB_ACTOR}"
    - name: Git push
      run: git push origin HEAD:${NEW_BRANCH}
    - name: Create Pull Request
      uses: actions/github-script@v3
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          github.pulls.create({
            ...context.repo,
            title: '${{ env.NEW_BRANCH }}',
            body: `Created by \`${ process.env.GITHUB_ACTOR }\``,
            head: '${{ env.NEW_BRANCH }}',
            base: 'master'
          })
```

### Close issue when title contains specific string
```yaml
name: issue-opened

on:
  issues:
    types: [opened]

jobs:
  debug:
    runs-on: ubuntu-latest
    if: contains(github.event.issue.title, 'Update APK')
    steps:
      - name: Close issue
        uses: actions/github-script@0.8.0
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            github.issues.update({
              ...context.repo,
              issue_number: context.issue.number,
              state: 'closed'
            })

            github.issues.createComment({
              ...context.repo,
              issue_number: context.issue.number,
              body: 'Close this!'
            });
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

### Deploy mkdocs to gh-pages
```yaml
name: Publish
on:
  push:
    branches:
      - master

jobs:
  deploy:
    name: Deploy docs
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v1

      - name: Deploy docs
        uses: mhausenblas/mkdocs-deploy-gh-pages@1.11
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Get other step output as enviroment in github-script
```yaml
jobs:
  debug:
    runs-on: ubuntu-latest
    steps:
      - id: update
        run: echo ::set-output name=message::okok
      - name: js
        uses: actions/github-script@0.8.0
        env:
          MESSAGE: ${{ steps.update.outputs.message }}
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            var message = process.env.MESSAGE
            if (message !== undefined){
              message == 'in'
            } else {
              message == 'else'
            }
            console.log(message)
```

### Docker build and push action
```yaml
name: docker-publish

on:
  push:

jobs:
  docker-publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # Build base image
      - uses: docker/build-push-action@v1
        with:
          username: _json_key
          password: ${{ secrets.GOOGLE_SA_GCR_JSON }}
          registry: asia.gcr.io
          repository: rammusxu/${{ github.event.repository.name }}
          tags: base
          target: base
          cache_froms: rammusxu/${{ github.event.repository.name }}:base

      # Build app image
      - uses: docker/build-push-action@v1
        with:
          username: _json_key
          password: ${{ secrets.GOOGLE_SA_GCR_JSON }}
          registry: asia.gcr.io
          repository: rammusxu/${{ github.event.repository.name }}
          tags: ${{ github.sha }}
          cache_froms: rammusxu/${{ github.event.repository.name }}:${{ github.sha }}
          tag_with_ref: true
```

## FAQ
### What's logic used in `push.branches` and `push.paths`
It's **AND** logic. It needs meet both conditions.

- Push to branch: `dev**`
- Something under `echo-box` folder changed
```
on:
  push:
    branches:
    - "dev**"
    paths:
    - 'echo-box/**'
```

### How to activate google service account in action

Should be `echo '${{ secrets.GOOGLE_SA_JSON }}'`

✅
```yaml
  debug2:
    runs-on: ubuntu-latest
    steps:
    - run: echo '${{ secrets.GOOGLE_SA_JSON }}' > sa.json
    - run: gcloud auth activate-service-account --key-file=sa.json
    - run: gsutil ls gs://rammus.dev
```

❌
```yaml
  debug:
    runs-on: ubuntu-latest
    steps:
    - run: echo "${{ secrets.GOOGLE_SA_JSON }}" > sa.json
    - run: gcloud auth activate-service-account --key-file=sa.json
    - run: gsutil ls gs://rammus.dev
```

### Can't load secrets in action.yaml
❌
```yaml
# action.yaml
inputs:
  kube_config:
    description: 'kubernetes config file'
    default: ${{ secrets.KUBE_CONFIG }}
    description: 'kubernetes config file. ex. ${{ secrets.KUBE_CONFIG }}'
```

### But ${{ github.token }} can be get in action.yaml
✅
```yaml
# action.yaml
inputs:
  auth_token:
    description: 'Auth token used to API'
    required: true
    default: "${{ github.token }}"
```

## Misc
### iOS App Build

[Bitrise](https://www.bitrise.io/pricing)

- Standard:
    - Available in Developer, Org Standard, Velocity plan
    - 2vCPU @ 2.7 GHz, 4 GB RAM
    - [pricing](https://www.bitrise.io/pricing) $90 / Month
- Elite:
    - Available in Org Elite, Velocity plan
    - 4vCPU @ 3.5 GHz, 8 GB RAM
    - [pricing](https://www.bitrise.io/pricing) $270 / Month

[Github Action](https://docs.github.com/en/free-pro-team@latest/actions/reference/specifications-for-github-hosted-runners#supported-runners-and-hardware-resources)

- 2 vCPU @ 2.60GHz, 7 GB RAM
- [princing](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-billing-and-payments-on-github/about-billing-for-github-actions) $0.08 / minute

### Build status

=== "Clickable"
    ```yaml
    [![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)](https://github.com/RammusXu/toolkit)
    ```

=== "Unclickable"
    ```yaml
    ![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)
    ```


- Clickable: [![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)](https://github.com/RammusXu/toolkit)
- Unclickable: ![Publish](https://github.com/RammusXu/toolkit/workflows/Publish/badge.svg)

## Env Sample
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
    - name: Dump GitHub context
      env:
        GITHUB_CONTEXT: ${{ toJson(github) }}
      run: echo "$GITHUB_CONTEXT"
```

### 2020-09-01 github context on push branch event

`${{ toJson(github) }}`

```json
{
  "token": "***",
  "job": "show-env",
  "ref": "refs/heads/github-pkg",
  "sha": "044271eda133bb9944f4aa7119bc661a8c1e9900",
  "repository": "rammusxu/action-demo",
  "repository_owner": "rammusxu",
  "repositoryUrl": "git://github.com/rammusxu/action-demo.git",
  "run_id": "221813086",
  "run_number": "166",
  "actor": "RammusXu",
  "workflow": "show-env",
  "head_ref": "",
  "base_ref": "",
  "event_name": "push",
  "event": {
    "after": "044271eda133bb9944f4aa7119bc661a8c1e9900",
    "base_ref": null,
    "before": "1c8b86a50a7bfb2d04984d5a67b414836aa04f22",
    "commits": [
      {
        "author": {
          "email": "comte_ken@hotmail.com",
          "name": "Rammus Xu",
          "username": "RammusXu"
        },
        "committer": {
          "email": "comte_ken@hotmail.com",
          "name": "Rammus Xu",
          "username": "RammusXu"
        },
        "distinct": true,
        "id": "044271eda133bb9944f4aa7119bc661a8c1e9900",
        "message": "Update docker login",
        "timestamp": "2020-08-24T17:56:16+08:00",
        "tree_id": "bf214120ff82ade624e0c2584c6e945c55ade8e3",
        "url": "https://github.com/rammusxu/action-demo/commit/044271eda133bb9944f4aa7119bc661a8c1e9900"
      }
    ],
    "compare": "https://github.com/rammusxu/action-demo/compare/1c8b86a50a7b...044271eda133",
    "created": false,
    "deleted": false,
    "forced": false,
    "head_commit": {
      "author": {
        "email": "comte_ken@hotmail.com",
        "name": "Rammus Xu",
        "username": "RammusXu"
      },
      "committer": {
        "email": "comte_ken@hotmail.com",
        "name": "Rammus Xu",
        "username": "RammusXu"
      },
      "distinct": true,
      "id": "044271eda133bb9944f4aa7119bc661a8c1e9900",
      "message": "Update docker login",
      "timestamp": "2020-08-24T17:56:16+08:00",
      "tree_id": "bf214120ff82ade624e0c2584c6e945c55ade8e3",
      "url": "https://github.com/rammusxu/action-demo/commit/044271eda133bb9944f4aa7119bc661a8c1e9900"
    },
    "organization": {
      "avatar_url": "https://avatars3.githubusercontent.com/u/36289044?v=4",
      "description": "The SWAG Life",
      "events_url": "https://api.github.com/orgs/rammusxu/events",
      "hooks_url": "https://api.github.com/orgs/rammusxu/hooks",
      "id": 36289044,
      "issues_url": "https://api.github.com/orgs/rammusxu/issues",
      "login": "rammusxu",
      "members_url": "https://api.github.com/orgs/rammusxu/members{/member}",
      "node_id": "MDEyOk9yZ2FuaXphdGlvbjM2Mjg5MDQ0",
      "public_members_url": "https://api.github.com/orgs/rammusxu/public_members{/member}",
      "repos_url": "https://api.github.com/orgs/rammusxu/repos",
      "url": "https://api.github.com/orgs/rammusxu"
    },
    "pusher": {
      "email": "comte_ken@hotmail.com",
      "name": "RammusXu"
    },
    "ref": "refs/heads/github-pkg",
    "repository": {
      "archive_url": "https://api.github.com/repos/rammusxu/action-demo/{archive_format}{/ref}",
      "archived": false,
      "assignees_url": "https://api.github.com/repos/rammusxu/action-demo/assignees{/user}",
      "blobs_url": "https://api.github.com/repos/rammusxu/action-demo/git/blobs{/sha}",
      "branches_url": "https://api.github.com/repos/rammusxu/action-demo/branches{/branch}",
      "clone_url": "https://github.com/rammusxu/action-demo.git",
      "collaborators_url": "https://api.github.com/repos/rammusxu/action-demo/collaborators{/collaborator}",
      "comments_url": "https://api.github.com/repos/rammusxu/action-demo/comments{/number}",
      "commits_url": "https://api.github.com/repos/rammusxu/action-demo/commits{/sha}",
      "compare_url": "https://api.github.com/repos/rammusxu/action-demo/compare/{base}...{head}",
      "contents_url": "https://api.github.com/repos/rammusxu/action-demo/contents/{+path}",
      "contributors_url": "https://api.github.com/repos/rammusxu/action-demo/contributors",
      "created_at": 1564547431,
      "default_branch": "master",
      "deployments_url": "https://api.github.com/repos/rammusxu/action-demo/deployments",
      "description": null,
      "disabled": false,
      "downloads_url": "https://api.github.com/repos/rammusxu/action-demo/downloads",
      "events_url": "https://api.github.com/repos/rammusxu/action-demo/events",
      "fork": false,
      "forks": 0,
      "forks_count": 0,
      "forks_url": "https://api.github.com/repos/rammusxu/action-demo/forks",
      "full_name": "rammusxu/action-demo",
      "git_commits_url": "https://api.github.com/repos/rammusxu/action-demo/git/commits{/sha}",
      "git_refs_url": "https://api.github.com/repos/rammusxu/action-demo/git/refs{/sha}",
      "git_tags_url": "https://api.github.com/repos/rammusxu/action-demo/git/tags{/sha}",
      "git_url": "git://github.com/rammusxu/action-demo.git",
      "has_downloads": true,
      "has_issues": true,
      "has_pages": true,
      "has_projects": true,
      "has_wiki": true,
      "homepage": null,
      "hooks_url": "https://api.github.com/repos/rammusxu/action-demo/hooks",
      "html_url": "https://github.com/rammusxu/action-demo",
      "id": 199778774,
      "issue_comment_url": "https://api.github.com/repos/rammusxu/action-demo/issues/comments{/number}",
      "issue_events_url": "https://api.github.com/repos/rammusxu/action-demo/issues/events{/number}",
      "issues_url": "https://api.github.com/repos/rammusxu/action-demo/issues{/number}",
      "keys_url": "https://api.github.com/repos/rammusxu/action-demo/keys{/key_id}",
      "labels_url": "https://api.github.com/repos/rammusxu/action-demo/labels{/name}",
      "language": "Dockerfile",
      "languages_url": "https://api.github.com/repos/rammusxu/action-demo/languages",
      "license": null,
      "master_branch": "master",
      "merges_url": "https://api.github.com/repos/rammusxu/action-demo/merges",
      "milestones_url": "https://api.github.com/repos/rammusxu/action-demo/milestones{/number}",
      "mirror_url": null,
      "name": "action-demo",
      "node_id": "MDEwOlJlcG9zaXRvcnkxOTk3Nzg3NzQ=",
      "notifications_url": "https://api.github.com/repos/rammusxu/action-demo/notifications{?since,all,participating}",
      "open_issues": 1,
      "open_issues_count": 1,
      "organization": "rammusxu",
      "owner": {
        "avatar_url": "https://avatars3.githubusercontent.com/u/36289044?v=4",
        "email": "engineering@swag.live",
        "events_url": "https://api.github.com/users/rammusxu/events{/privacy}",
        "followers_url": "https://api.github.com/users/rammusxu/followers",
        "following_url": "https://api.github.com/users/rammusxu/following{/other_user}",
        "gists_url": "https://api.github.com/users/rammusxu/gists{/gist_id}",
        "gravatar_id": "",
        "html_url": "https://github.com/rammusxu",
        "id": 36289044,
        "login": "rammusxu",
        "name": "rammusxu",
        "node_id": "MDEyOk9yZ2FuaXphdGlvbjM2Mjg5MDQ0",
        "organizations_url": "https://api.github.com/users/rammusxu/orgs",
        "received_events_url": "https://api.github.com/users/rammusxu/received_events",
        "repos_url": "https://api.github.com/users/rammusxu/repos",
        "site_admin": false,
        "starred_url": "https://api.github.com/users/rammusxu/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/rammusxu/subscriptions",
        "type": "Organization",
        "url": "https://api.github.com/users/rammusxu"
      },
      "private": true,
      "pulls_url": "https://api.github.com/repos/rammusxu/action-demo/pulls{/number}",
      "pushed_at": 1598262984,
      "releases_url": "https://api.github.com/repos/rammusxu/action-demo/releases{/id}",
      "size": 245,
      "ssh_url": "git@github.com:rammusxu/action-demo.git",
      "stargazers": 0,
      "stargazers_count": 0,
      "stargazers_url": "https://api.github.com/repos/rammusxu/action-demo/stargazers",
      "statuses_url": "https://api.github.com/repos/rammusxu/action-demo/statuses/{sha}",
      "subscribers_url": "https://api.github.com/repos/rammusxu/action-demo/subscribers",
      "subscription_url": "https://api.github.com/repos/rammusxu/action-demo/subscription",
      "svn_url": "https://github.com/rammusxu/action-demo",
      "tags_url": "https://api.github.com/repos/rammusxu/action-demo/tags",
      "teams_url": "https://api.github.com/repos/rammusxu/action-demo/teams",
      "trees_url": "https://api.github.com/repos/rammusxu/action-demo/git/trees{/sha}",
      "updated_at": "2020-08-24T06:36:17Z",
      "url": "https://github.com/rammusxu/action-demo",
      "watchers": 0,
      "watchers_count": 0
    },
    "sender": {
      "avatar_url": "https://avatars1.githubusercontent.com/u/4367069?v=4",
      "events_url": "https://api.github.com/users/RammusXu/events{/privacy}",
      "followers_url": "https://api.github.com/users/RammusXu/followers",
      "following_url": "https://api.github.com/users/RammusXu/following{/other_user}",
      "gists_url": "https://api.github.com/users/RammusXu/gists{/gist_id}",
      "gravatar_id": "",
      "html_url": "https://github.com/RammusXu",
      "id": 4367069,
      "login": "RammusXu",
      "node_id": "MDQ6VXNlcjQzNjcwNjk=",
      "organizations_url": "https://api.github.com/users/RammusXu/orgs",
      "received_events_url": "https://api.github.com/users/RammusXu/received_events",
      "repos_url": "https://api.github.com/users/RammusXu/repos",
      "site_admin": false,
      "starred_url": "https://api.github.com/users/RammusXu/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/RammusXu/subscriptions",
      "type": "User",
      "url": "https://api.github.com/users/RammusXu"
    }
  },
  "server_url": "https://github.com",
  "api_url": "https://api.github.com",
  "graphql_url": "https://api.github.com/graphql",
  "workspace": "/home/runner/work/action-demo/action-demo",
  "action": "run3",
  "event_path": "/home/runner/work/_temp/_github_workflow/event.json"
}
```

`cat $GITHUB_EVENT_PATH`

```json
{
  "after": "044271eda133bb9944f4aa7119bc661a8c1e9900",
  "base_ref": null,
  "before": "1c8b86a50a7bfb2d04984d5a67b414836aa04f22",
  "commits": [
    {
      "author": {
        "email": "comte_ken@hotmail.com",
        "name": "Rammus Xu",
        "username": "RammusXu"
      },
      "committer": {
        "email": "comte_ken@hotmail.com",
        "name": "Rammus Xu",
        "username": "RammusXu"
      },
      "distinct": true,
      "id": "044271eda133bb9944f4aa7119bc661a8c1e9900",
      "message": "Update docker login",
      "timestamp": "2020-08-24T17:56:16+08:00",
      "tree_id": "bf214120ff82ade624e0c2584c6e945c55ade8e3",
      "url": "https://github.com/rammusxu/action-demo/commit/044271eda133bb9944f4aa7119bc661a8c1e9900"
    }
  ],
  "compare": "https://github.com/rammusxu/action-demo/compare/1c8b86a50a7b...044271eda133",
  "created": false,
  "deleted": false,
  "forced": false,
  "head_commit": {
    "author": {
      "email": "comte_ken@hotmail.com",
      "name": "Rammus Xu",
      "username": "RammusXu"
    },
    "committer": {
      "email": "comte_ken@hotmail.com",
      "name": "Rammus Xu",
      "username": "RammusXu"
    },
    "distinct": true,
    "id": "044271eda133bb9944f4aa7119bc661a8c1e9900",
    "message": "Update docker login",
    "timestamp": "2020-08-24T17:56:16+08:00",
    "tree_id": "bf214120ff82ade624e0c2584c6e945c55ade8e3",
    "url": "https://github.com/rammusxu/action-demo/commit/044271eda133bb9944f4aa7119bc661a8c1e9900"
  },
  "organization": {
    "avatar_url": "https://avatars3.githubusercontent.com/u/36289044?v=4",
    "description": "The SWAG Life",
    "events_url": "https://api.github.com/orgs/rammusxu/events",
    "hooks_url": "https://api.github.com/orgs/rammusxu/hooks",
    "id": 36289044,
    "issues_url": "https://api.github.com/orgs/rammusxu/issues",
    "login": "rammusxu",
    "members_url": "https://api.github.com/orgs/rammusxu/members{/member}",
    "node_id": "MDEyOk9yZ2FuaXphdGlvbjM2Mjg5MDQ0",
    "public_members_url": "https://api.github.com/orgs/rammusxu/public_members{/member}",
    "repos_url": "https://api.github.com/orgs/rammusxu/repos",
    "url": "https://api.github.com/orgs/rammusxu"
  },
  "pusher": {
    "email": "comte_ken@hotmail.com",
    "name": "RammusXu"
  },
  "ref": "refs/heads/github-pkg",
  "repository": {
    "archive_url": "https://api.github.com/repos/rammusxu/action-demo/{archive_format}{/ref}",
    "archived": false,
    "assignees_url": "https://api.github.com/repos/rammusxu/action-demo/assignees{/user}",
    "blobs_url": "https://api.github.com/repos/rammusxu/action-demo/git/blobs{/sha}",
    "branches_url": "https://api.github.com/repos/rammusxu/action-demo/branches{/branch}",
    "clone_url": "https://github.com/rammusxu/action-demo.git",
    "collaborators_url": "https://api.github.com/repos/rammusxu/action-demo/collaborators{/collaborator}",
    "comments_url": "https://api.github.com/repos/rammusxu/action-demo/comments{/number}",
    "commits_url": "https://api.github.com/repos/rammusxu/action-demo/commits{/sha}",
    "compare_url": "https://api.github.com/repos/rammusxu/action-demo/compare/{base}...{head}",
    "contents_url": "https://api.github.com/repos/rammusxu/action-demo/contents/{+path}",
    "contributors_url": "https://api.github.com/repos/rammusxu/action-demo/contributors",
    "created_at": 1564547431,
    "default_branch": "master",
    "deployments_url": "https://api.github.com/repos/rammusxu/action-demo/deployments",
    "description": null,
    "disabled": false,
    "downloads_url": "https://api.github.com/repos/rammusxu/action-demo/downloads",
    "events_url": "https://api.github.com/repos/rammusxu/action-demo/events",
    "fork": false,
    "forks": 0,
    "forks_count": 0,
    "forks_url": "https://api.github.com/repos/rammusxu/action-demo/forks",
    "full_name": "rammusxu/action-demo",
    "git_commits_url": "https://api.github.com/repos/rammusxu/action-demo/git/commits{/sha}",
    "git_refs_url": "https://api.github.com/repos/rammusxu/action-demo/git/refs{/sha}",
    "git_tags_url": "https://api.github.com/repos/rammusxu/action-demo/git/tags{/sha}",
    "git_url": "git://github.com/rammusxu/action-demo.git",
    "has_downloads": true,
    "has_issues": true,
    "has_pages": true,
    "has_projects": true,
    "has_wiki": true,
    "homepage": null,
    "hooks_url": "https://api.github.com/repos/rammusxu/action-demo/hooks",
    "html_url": "https://github.com/rammusxu/action-demo",
    "id": 199778774,
    "issue_comment_url": "https://api.github.com/repos/rammusxu/action-demo/issues/comments{/number}",
    "issue_events_url": "https://api.github.com/repos/rammusxu/action-demo/issues/events{/number}",
    "issues_url": "https://api.github.com/repos/rammusxu/action-demo/issues{/number}",
    "keys_url": "https://api.github.com/repos/rammusxu/action-demo/keys{/key_id}",
    "labels_url": "https://api.github.com/repos/rammusxu/action-demo/labels{/name}",
    "language": "Dockerfile",
    "languages_url": "https://api.github.com/repos/rammusxu/action-demo/languages",
    "license": null,
    "master_branch": "master",
    "merges_url": "https://api.github.com/repos/rammusxu/action-demo/merges",
    "milestones_url": "https://api.github.com/repos/rammusxu/action-demo/milestones{/number}",
    "mirror_url": null,
    "name": "action-demo",
    "node_id": "MDEwOlJlcG9zaXRvcnkxOTk3Nzg3NzQ=",
    "notifications_url": "https://api.github.com/repos/rammusxu/action-demo/notifications{?since,all,participating}",
    "open_issues": 1,
    "open_issues_count": 1,
    "organization": "rammusxu",
    "owner": {
      "avatar_url": "https://avatars3.githubusercontent.com/u/36289044?v=4",
      "email": "engineering@swag.live",
      "events_url": "https://api.github.com/users/rammusxu/events{/privacy}",
      "followers_url": "https://api.github.com/users/rammusxu/followers",
      "following_url": "https://api.github.com/users/rammusxu/following{/other_user}",
      "gists_url": "https://api.github.com/users/rammusxu/gists{/gist_id}",
      "gravatar_id": "",
      "html_url": "https://github.com/rammusxu",
      "id": 36289044,
      "login": "rammusxu",
      "name": "rammusxu",
      "node_id": "MDEyOk9yZ2FuaXphdGlvbjM2Mjg5MDQ0",
      "organizations_url": "https://api.github.com/users/rammusxu/orgs",
      "received_events_url": "https://api.github.com/users/rammusxu/received_events",
      "repos_url": "https://api.github.com/users/rammusxu/repos",
      "site_admin": false,
      "starred_url": "https://api.github.com/users/rammusxu/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/rammusxu/subscriptions",
      "type": "Organization",
      "url": "https://api.github.com/users/rammusxu"
    },
    "private": true,
    "pulls_url": "https://api.github.com/repos/rammusxu/action-demo/pulls{/number}",
    "pushed_at": 1598262984,
    "releases_url": "https://api.github.com/repos/rammusxu/action-demo/releases{/id}",
    "size": 245,
    "ssh_url": "git@github.com:rammusxu/action-demo.git",
    "stargazers": 0,
    "stargazers_count": 0,
    "stargazers_url": "https://api.github.com/repos/rammusxu/action-demo/stargazers",
    "statuses_url": "https://api.github.com/repos/rammusxu/action-demo/statuses/{sha}",
    "subscribers_url": "https://api.github.com/repos/rammusxu/action-demo/subscribers",
    "subscription_url": "https://api.github.com/repos/rammusxu/action-demo/subscription",
    "svn_url": "https://github.com/rammusxu/action-demo",
    "tags_url": "https://api.github.com/repos/rammusxu/action-demo/tags",
    "teams_url": "https://api.github.com/repos/rammusxu/action-demo/teams",
    "trees_url": "https://api.github.com/repos/rammusxu/action-demo/git/trees{/sha}",
    "updated_at": "2020-08-24T06:36:17Z",
    "url": "https://github.com/rammusxu/action-demo",
    "watchers": 0,
    "watchers_count": 0
  },
  "sender": {
    "avatar_url": "https://avatars1.githubusercontent.com/u/4367069?v=4",
    "events_url": "https://api.github.com/users/RammusXu/events{/privacy}",
    "followers_url": "https://api.github.com/users/RammusXu/followers",
    "following_url": "https://api.github.com/users/RammusXu/following{/other_user}",
    "gists_url": "https://api.github.com/users/RammusXu/gists{/gist_id}",
    "gravatar_id": "",
    "html_url": "https://github.com/RammusXu",
    "id": 4367069,
    "login": "RammusXu",
    "node_id": "MDQ6VXNlcjQzNjcwNjk=",
    "organizations_url": "https://api.github.com/users/RammusXu/orgs",
    "received_events_url": "https://api.github.com/users/RammusXu/received_events",
    "repos_url": "https://api.github.com/users/RammusXu/repos",
    "site_admin": false,
    "starred_url": "https://api.github.com/users/RammusXu/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/RammusXu/subscriptions",
    "type": "User",
    "url": "https://api.github.com/users/RammusXu"
  }
}
```

`env`

```bash
LEIN_HOME=/usr/local/lib/lein
M2_HOME=/usr/share/apache-maven-3.6.3
GOROOT_1_11_X64=/opt/hostedtoolcache/go/1.11.13/x64
ANDROID_HOME=/usr/local/lib/android/sdk
JAVA_HOME_11_X64=/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64
ImageVersion=20200817.1
AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
LANG=C.UTF-8
AZURE_EXTENSION_DIR=/opt/az/azcliextensions
POWERSHELL_DISTRIBUTION_CHANNEL=GitHub-Actions-ubuntu18
GITHUB_API_URL=https://api.github.com
INVOCATION_ID=dcb35bf82e314cdb9caa479c88a6c37e
BOOST_ROOT_1_72_0=/opt/hostedtoolcache/boost/1.72.0/x64
JAVA_HOME_12_X64=/usr/lib/jvm/adoptopenjdk-12-hotspot-amd64
ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
RUNNER_TOOL_CACHE=/opt/hostedtoolcache
SWIFT_PATH=/usr/share/swift/usr/bin
JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
RUNNER_TRACKING_ID=github_0e3e53f2-73ff-4e23-8e4f-52cb37f62b82
DOTNET_MULTILEVEL_LOOKUP="0"
GITHUB_REPOSITORY_OWNER=rammusxu
GITHUB_ACTIONS=true
DOTNET_SKIP_FIRST_TIME_EXPERIENCE="1"
CI=true
DOTNET_NOLOGO="1"
USER=runner
GITHUB_HEAD_REF=
GITHUB_ACTOR=RammusXu
GITHUB_ACTION=run2
GRADLE_HOME=/usr/share/gradle
PWD=/home/runner/work/action-demo/action-demo
ImageOS=ubuntu18
HOME=/home/runner
GOROOT=/opt/hostedtoolcache/go/1.14.7/x64
JOURNAL_STREAM=9:31545
GOROOT_1_14_X64=/opt/hostedtoolcache/go/1.14.7/x64
JAVA_HOME_8_X64=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
RUNNER_TEMP=/home/runner/work/_temp
GOROOT_1_15_X64=/opt/hostedtoolcache/go/1.15.0/x64
CONDA=/usr/share/miniconda
GOROOT_1_13_X64=/opt/hostedtoolcache/go/1.13.15/x64
BOOST_ROOT_1_69_0=/opt/hostedtoolcache/boost/1.69.0/x64
DEBIAN_FRONTEND=noninteractive
RUNNER_WORKSPACE=/home/runner/work/action-demo
GITHUB_REF=refs/heads/github-pkg
GITHUB_SHA=044271eda133bb9944f4aa7119bc661a8c1e9900
GITHUB_RUN_ID=221813086
GITHUB_SERVER_URL=https://github.com
GOROOT_1_12_X64=/opt/hostedtoolcache/go/1.12.17/x64
GECKOWEBDRIVER=/usr/local/share/gecko_driver
DEPLOYMENT_BASEPATH=/opt/runner
GITHUB_EVENT_PATH=/home/runner/work/_temp/_github_workflow/event.json
CHROMEWEBDRIVER=/usr/local/share/chrome_driver
HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
GITHUB_GRAPHQL_URL=https://api.github.com/graphql
RUNNER_OS=Linux
GITHUB_BASE_REF=
VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg
GITHUB_JOB=show-env
PERFLOG_LOCATION_SETTING=RUNNER_PERFLOG
JAVA_HOME_7_X64=/usr/lib/jvm/zulu-7-azure-amd64
RUNNER_USER=runner
SHLVL=1
HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
GITHUB_REPOSITORY=rammusxu/action-demo
GITHUB_EVENT_NAME=push
LEIN_JAR=/usr/local/lib/lein/self-installs/leiningen-2.9.4-standalone.jar
GITHUB_RUN_NUMBER=166
RUNNER_PERFLOG=/home/runner/perflog
GITHUB_WORKFLOW=show-env
ANT_HOME=/usr/share/ant
PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/share/rust/.cargo/bin:/home/runner/.config/composer/vendor/bin:/home/runner/.dotnet/tools:/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
SELENIUM_JAR_PATH=/usr/share/java/selenium-server-standalone.jar
GITHUB_WORKSPACE=/home/runner/work/action-demo/action-demo
CHROME_BIN=/usr/bin/google-chrome
HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
_=/usr/bin/env
```

### 2020-05-18 Github workflow env on pull request
```bash
LEIN_HOME=/usr/local/lib/lein
M2_HOME=/usr/share/apache-maven-3.6.3
GOROOT_1_11_X64=/usr/local/go1.11
ANDROID_HOME=/usr/local/lib/android/sdk
JAVA_HOME_11_X64=/usr/lib/jvm/zulu-11-azure-amd64
ImageVersion=20200430.1
AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
LANG=C.UTF-8
AZURE_EXTENSION_DIR=/opt/az/azcliextensions
POWERSHELL_DISTRIBUTION_CHANNEL=GitHub-Actions-ubuntu18
INVOCATION_ID=68f93b53277249cc8519235cea6396c9
BOOST_ROOT_1_72_0=/usr/local/share/boost/1.72.0
JAVA_HOME_12_X64=/usr/lib/jvm/zulu-12-azure-amd64
ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
RUNNER_TOOL_CACHE=/opt/hostedtoolcache
SWIFT_PATH=/usr/share/swift/usr/bin
JAVA_HOME=/usr/lib/jvm/zulu-8-azure-amd64
RUNNER_TRACKING_ID=github_884bb8e2-7879-4810-9c99-0192e58487e7
GITHUB_REPOSITORY_OWNER=rammusxu
GITHUB_ACTIONS=true
DOTNET_SKIP_FIRST_TIME_EXPERIENCE="1"
CI=true
USER=runner
GITHUB_HEAD_REF=try-deploy
GITHUB_ACTOR=RammusXu
GITHUB_ACTION=run
GRADLE_HOME=/usr/share/gradle
PWD=/home/runner/work/action-demo/action-demo
ImageOS=ubuntu18
HOME=/home/runner
GOROOT=/usr/local/go1.14
JOURNAL_STREAM=9:31391
GOROOT_1_14_X64=/usr/local/go1.14
JAVA_HOME_8_X64=/usr/lib/jvm/zulu-8-azure-amd64
RUNNER_TEMP=/home/runner/work/_temp
CONDA=/usr/share/miniconda
GOROOT_1_13_X64=/usr/local/go1.13
BOOST_ROOT_1_69_0=/usr/local/share/boost/1.69.0
DEBIAN_FRONTEND=noninteractive
RUNNER_WORKSPACE=/home/runner/work/action-demo
GITHUB_REF=refs/pull/37/merge
GITHUB_SHA=aadf39660fb8c0f87565bc08db9403f5197a8de6
GITHUB_RUN_ID=107752396
GOROOT_1_12_X64=/usr/local/go1.12
GECKOWEBDRIVER=/usr/local/share/gecko_driver
DEPLOYMENT_BASEPATH=/opt/runner
GITHUB_EVENT_PATH=/home/runner/work/_temp/_github_workflow/event.json
CHROMEWEBDRIVER=/usr/local/share/chrome_driver
HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
RUNNER_OS=Linux
GITHUB_BASE_REF=master
VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg
GITHUB_JOB=test
PERFLOG_LOCATION_SETTING=RUNNER_PERFLOG
JAVA_HOME_7_X64=/usr/lib/jvm/zulu-7-azure-amd64
RUNNER_USER=runner
SHLVL=1
HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
GITHUB_REPOSITORY=rammusxu/action-demo
GITHUB_EVENT_NAME=pull_request
LEIN_JAR=/usr/local/lib/lein/self-installs/leiningen-2.9.3-standalone.jar
GITHUB_RUN_NUMBER=5
RUNNER_PERFLOG=/home/runner/perflog
GITHUB_WORKFLOW=.github/workflows/update-status.yaml
ANT_HOME=/usr/share/ant
PATH=/usr/share/rust/.cargo/bin:/home/runner/.config/composer/vendor/bin:/home/runner/.dotnet/tools:/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin
SELENIUM_JAR_PATH=/usr/share/java/selenium-server-standalone.jar
GITHUB_WORKSPACE=/home/runner/work/action-demo/action-demo
CHROME_BIN=/usr/bin/google-chrome
HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
2Z _=/usr/bin/env
```

### 2020-03-11 Use a self build action
```bash
/usr/bin/docker run --name e87b528978e939d04c5cabae17f516da08bb2a_79b912 --label e87b52 --workdir /github/workspace --rm -e INPUT_ARGS -e INPUT_MY_VAR -e INPUT_LOWER_VAR -e INPUT_WHO-TO-GREET -e INPUT_NAME -e HOME -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e RUNNER_OS -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/action-demo/action-demo":"/github/workspace" e87b52:8978e939d04c5cabae17f516da08bb2a env
```

## Reference
- https://help.github.com/en/actions/reference
- https://github.com/actions/toolkit/tree/master/packages/github
- https://github.com/actions/github-script
- https://octokit.github.io/rest.js/#usage
- bin in Ubuntu 18.04 https://github.com/actions/virtual-environments/blob/master/images/linux/Ubuntu1804-README.md
