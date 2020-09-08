#!/bin/sh

if [[ "$(cat $GITHUB_EVENT_PATH | jq -r '.pull_request.merged')" != 'true' ]]; then
    echo "Skip delete-branch-after-pr-merged"
    exit 0
fi

http DELETE "https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs/heads/$GITHUB_HEAD_REF" \
    "Authorization: token $INPUT_AUTH_TOKEN"
