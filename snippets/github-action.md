

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
if: steps.set-env.outputs.message

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