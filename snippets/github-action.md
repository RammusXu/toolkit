
## On Trigger Event
```

on:
  push:
    branches:
      - "master"
      - "**"
    tags:
      - "**"
  repository_dispatch:
    types: [rammus_post]
```

## Pass variables
```
echo ::set-output name=message::$output_message
echo ::set-env name=action_state::yellow
```

## Use variables
```
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
PR_COMMENT_URL: ${{ github.event.pull_request.comments_url }}
PR_COMMENT: ${{ steps.message.outputs.message }}
```

## if condition
```
if: contains(github.ref, 'tags')
if: steps.git-diff.outputs.is-diff
if: steps.set-env.outputs.message == 'hello'
if: github.event.action == 'rammus_post'
```

## Setting
```
ACTIONS_RUNNER_DEBUG: true
```

## Awesome Actions
Docker login 
```
    - name: Docker Login - docker.pkg.github.com
      uses: swaglive/actions/docker/login@944b742
      with:
        password: ${{ secrets.GHR_PASSWORD }}
        username: ${{ secrets.GHR_USERNAME }}
        url: docker.pkg.github.com
```

Cache node_modules
```
      - uses: actions/cache@v1
        with:
          path: ./node_modules
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-
```

Fetch private submodule
```
```

Create pull request
```
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
```


## Test workflows
https://github.com/swaglive/action-demo/commit/4b0528f1fbfb125e98850f7ea9fb1d6ec32b46ac/checks?check_suite_id=382701123
```
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

```
## Ramms
INPUT_GITHUB_TOKEN=
INPUT_COMMENT_URL="https://api.github.com/repos/swaglive/action-demo/dispatches"

curl -H "Authorization: token $INPUT_GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    -d '{"event_type":"deploy_swag_bot","client_payload":{"new_version_image":"echo-server:96b2166", "new_version_sha":"96b2166","actor":"Rammus Xu"}}' \
    -XPOST $INPUT_COMMENT_URL

```
