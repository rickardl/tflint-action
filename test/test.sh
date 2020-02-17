#!/usr/bin/env bash

. ../entrypoint.sh --source-only

before() {

    export GITHUB_WORKSPACE=""

    export TFLINT_ACTION_TERRAFORM_FOLDER="."
    export TFLINT_ACTION_TFLINT_OPTS=""

    export TERRAFORM_LOCATION="${TFLINT_ACTION_TERRAFORM_FOLDER:-$GITHUB_WORKSPACE}"
    export TFLINT_OPTS="${TFLINT_ACTION_TFLINT_OPTS:-}"
}

test_app() {
    response=$(curl --location --request GET 'https://postman-echo.com/status/200')
    echo "$response" | grep -q "${RESPONSE_CODE}"
}

after() {
    unset RESPONSE_CODE
}
