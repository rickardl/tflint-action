#!/bin/bash

set -exo pipefail
# Author: Rickard Löfström <rickard.lofstrom@teliacompany.com>

function print_message() {
  echo "$1" >&2
}

function parse_exitcode() {

  local tflint_exitcode=$1
  local tflint_status="Failed"

  # TFLint returns the following exit statuses on exit: 0: No issues foun 2: Errors occurred 3: No errors occurred, but issues found
  if [ "${tflint_exitcode}" -eq 0 ]; then
    tflint_status="Success"
  elif [ "${tflint_exitcode}" -eq 2 ]; then
    tflint_status="Failed"
  else
    [ "${tflint_exitcode}" -eq 3 ]
    tflint_status="Warning"
  fi

  echo "$tflint_status"

}

function format_comment() {

  local tflint_output="$1"
  local tflint_status_code="$2"
  local tflint_status_state

  tflint_status_state=$(parse_exitcode "${tflint_status_code}")

  local comment
  comment="#### \`Terraform TFlint\` ${tflint_status_state} <details><summary>Show Output</summary>
  <p>
  \`\`\`hcl
  ${tflint_output}
  \`\`\`
  </p>
  </details>"

  echo "$comment"
}

function get_url() {

  local url=""
  local github_event_path=$1
  url=$(jq -r .pull_request.comments_url "${github_event_path}")

  echo "$url"
}

function is_pull_request() {
  local github_event_name
  github_event_name="$1"

  echo [ "${github_event_name}" == "pull_request" ]

}

function is_comment_enabled() {

  local is_enabled="$1"

  # Comment on the pull request if necessary.
  echo [ "${is_enabled}" == "1" ] || [ "${is_enabled}" == "true" ]
}

function post_comment() {

  local comment=$1
  local github_event_name=$2
  local github_token=$3
  local url=$4
  local dry_run="${5:-0}"
  local payload

  if [ -n "${github_token}" ] && [ -n "${url}" ] && [ -n "${comment}" ]; then
    payload=$(echo "${comment}" | jq -R --slurp '{body: .}')
    if [ "${dry_run}" -eq 1 ]; then
      echo "::debug::sending comment ${comment} to ${url}"
      echo "${payload}" | curl -s -S -H "Authorization: token ${github_token}" --header "Content-Type: application/json" --data @- "${url}" >/dev/null
    else
      echo "::debug::dry-run sending comment ${comment} to ${url}"
    fi
  else
    echo "::debug::check token, comment is ${comment} and url is ${url}"

    echo 1
  fi
}

function is_comment_available() {

  local tflint_exitcode="$1"
  echo [ "${tflint_exitcode}" != "0" ]
}

function main() {

  declare GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_TOKEN

  local terraform_location="${INPUT_TFLINT_ACTION_FOLDER:-$GITHUB_WORKSPACE}"
  local tflint_opts="${INPUT_TFLINT_ACTION__OPTS:-}"
  local tflint_action_comment="${INPUT_TFLINT_ACTION_COMMENT:-0}"

  local github_event_type="${GITHUB_EVENT_NAME}"
  local github_event_path="${GITHUB_EVENT_PATH}"
  local github_token="${GITHUB_TOKEN}"

  local tflint_output
  local tflint_exitcode

  if [ -x "$(command -v tflint)" ]; then

    local tflint_parameters
    # shellcheck disable=SC2086,SC2116
    tflint_parameters=$(echo ${tflint_opts} ${terraform_location})
    # shellcheck disable=SC2086,SC2116
    tflint_output=$(tflint --no-color $tflint_parameters)
    tflint_exitcode=${?}

    comment_enabled=$(is_comment_enabled "${tflint_action_comment}")
    pull_request=$(is_pull_request "${github_event_type}")

    ## We should only send a comment if we have comments enabled, it's a pull-request and we have a github token
    if [ "$pull_request" -eq 1 ]; then

      if [ -n "$github_token" ]; then

        local comment_available
        comment_available=$(is_comment_available "${tflint_exitcode}")

        if [ "$comment_available" -eq 1 ] && [ "$comment_enabled" -eq 1 ]; then

          local comment
          comment=$(format_comment "${tflint_output}" "${tflint_exitcode}")
          url=$(get_url "$GITHUB_EVENT_PATH")
          post_comment "${comment}" "${github_event_type}" "${github_token}" "${url}"

        else
          echo "::debug::No comment available"

        fi

      else
        echo "::debug::GITHUB_TOKEN is required to perform this action"

      fi
    else
      echo "::debug::The event name was ${GITHUB_EVENT}"

    fi

    echo "::set-output name=tf_lint_output::${tflint_output}"
    echo "::set-output name=tf_lint_status::${tflint_status}"

    exit "$tflint_exitcode"

  else

    echo "::debug::tflint is required to perform this action"
    exit 1

  fi

}

# shellcheck disable=SC1234
if [ "${1}" != "--source-only" ]; then
  main "${@}"
fi
