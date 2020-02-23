#!/usr/bin/env bash

. ../entrypoint.sh --source-only

set -x

before() {

    export GITHUB_WORKSPACE=""

    export TFLINT_ACTION_TERRAFORM_FOLDER="."
    export TFLINT_ACTION_TFLINT_OPTS=""

    export TERRAFORM_LOCATION="${TFLINT_ACTION_TERRAFORM_FOLDER:-$GITHUB_WORKSPACE}"
    export TFLINT_OPTS="${TFLINT_ACTION_TFLINT_OPTS:-}"
    export GITHUB_EVENT_PATH="event.json"
}

test_is_comment_enabled() {
    local tflint_exitcode=1
    expected=1
    actual=$(is_comment_available "${tflint_exitcode}")

    echo "$actual" -eq "$expected"

}

test_is_pull_request() {
    local github_event_type="pull-request"
    expected=1
    actual=$(is_pull_request "$github_event_type")
    echo "$actual" -eq "$expected"

}

test_get_url() {
    expected="https://api.github.com/repos/Codertocat/Hello-World/pulls/2/comments"
    actual=$(get_url "$GITHUB_EVENT_PATH")

    echo "$actual" -eq "$expected"
}

test_format_comment_bad() {
    local tflint_output
    tflint_output=$(cat data/tflint_bad.txt)
    local tflint_status_code=1
    expected=$(cat data/tflint_bad_result.txt)
    actual=$(format_comment "$tflint_output" "$tflint_status_code")
    echo "$actual" -eq "$expected"

}

test_send_comment() {
    local comment
    comment=$(cat data/tflint_bad_result.txt)
    local github_event_type="pull-request"
    local github_token="XXXXX"
    local url="https://api.github.com/repos/Codertocat/Hello-World/pulls/2/comments"
    local dry_run=1

    expected=0
    actual=$(post_comment "${comment}" "${github_event_type}" "${github_token}" "${url}" "${dry_run}")
    echo "$actual" -eq "$expected"

}

after() {
    unset GITHUB_WORKSPACE
    unset TFLINT_ACTION_TERRAFORM_FOLDER
    unset TFLINT_ACTION_TFLINT_OPTS
    unset TERRAFORM_LOCATION
    unset GITHUB_EVENT_PATH

}
