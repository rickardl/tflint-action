#!/bin/bash
TERRAFORM_LOCATION="${TFLINT_ACTION_TERRAFORM_FOLDER:-"/github/workspace"}"
TFLINT_OPTS="${TFLINT_ACTION_TFLINT_OPTS:-}"
TFLINT_OUTPUT=$(tflint "$TFLINT_OPTS" "$TERRAFORM_LOCATION")
TFLINT_EXITCODE=${?}

# TFLint returns the following exit statuses on exit: 0: No issues foun 2: Errors occurred 3: No errors occurred, but issues found
if [ ${TFLINT_EXITCODE} -eq 0 ]; then
  TFLINT_STATUS="Success"
elif [ ${TFLINT_EXITCODE} -eq 2 ]; then
  TFLINT_STATUS="Failed"
else
  [ ${TFLINT_EXITCODE} -eq 3 ]
  TFLINT_STATUS="Warning"
fi

# Print output.
echo "${TFLINT_OUTPUT}"

# Comment on the pull request if necessary.
if [ "${INPUT_TFLINT_ACTIONS_COMMENT}" == "1" ] || [ "${INPUT_TFLINT_ACTIONS_COMMENT}" == "true" ]; then
  TFLINT_COMMENT=1
else
  TFLINT_COMMENT=0
fi

if [ "${GITHUB_EVENT_NAME}" == "pull_request" ] && [ -n "${GITHUB_TOKEN}" ] && [ "${TFLINT_COMMENT}" == "1" ] && [ "${TFLINT_EXITCODE}" != "0" ]; then
  COMMENT="#### \`Terraform TFlint Scan\` ${TFLINT_STATUS}
<details><summary>Show Output</summary>
<p>

\`\`\`hcl
$(/go/bin/tflint /github/workspace --no-color)
\`\`\`

</p>
</details>"
  PAYLOAD=$(echo "${COMMENT}" | jq -R --slurp '{body: .}')
  URL=$(jq -r .pull_request.comments_url "${GITHUB_EVENT_PATH}")
  echo "${PAYLOAD}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${URL}" >/dev/null
fi

exit $TFLINT_EXITCODE
