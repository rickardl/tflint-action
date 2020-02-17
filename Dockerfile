# pinned version of the Alpine-tagged 'go' image
FROM alpine:3.9 as downloader
# install requirements
# hadolint ignore=DL3018
RUN apk add --update --no-cache bash ca-certificates curl jq
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o /tmp/tflint.zip && unzip /tmp/tflint.zip -d /tmp/ && rm /tmp/tflint.zip

FROM alpine:3.9

LABEL version="1.7.0"
LABEL name="tflint-action"
LABEL repository="http://github.com/telia-oss/tflint-action"
LABEL homepage="http://github.com/telia-oss/tflint-action"
LABEL maintainer="Rickard Löfström <rickard.lofstrom@teliacompany.com>"

LABEL "com.github.actions.name"="tflint"
LABEL "com.github.actions.description"="Runs tflint against PR's to validate there are no violations"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="red"

# hadolint ignore=DL3018
RUN apk add --update --no-cache bash ca-certificates curl jq
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY --from=downloader /tmp/tflint /usr/local/bin/tflint
COPY entrypoint.sh /entrypoint.sh
# set the default entrypoint -- when this container is run, use this command
ENTRYPOINT ["/entrypoint.sh"]
