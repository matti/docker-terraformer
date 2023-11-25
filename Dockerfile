FROM ubuntu:22.04 as base
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates curl unzip

FROM base as terraform
RUN set -eux ; \
  mkdir /ghjk && cd /ghjk ; \
  curl -Lfo "terraform.zip" "https://releases.hashicorp.com/terraform/1.6.1/terraform_1.6.1_linux_${TARGETARCH}.zip" ; \
  unzip terraform.zip ; \
  mv terraform / ; \
  rm -rf /ghjk

FROM base as terraformer-all
RUN set -eux ; \
  curl -Lf -o /terraformer "https://github.com/GoogleCloudPlatform/terraformer/releases/download/0.8.24/terraformer-all-linux-${TARGETARCH}" ; \
  chmod +x terraformer

FROM base
ENV PROMPT_COMMAND="history -a"
ENV AWS_PAGER=""

RUN set -eux ; \
  apt-get update && apt-get install --no-install-recommends -y \
  iputils-ping dnsutils curl

COPY --from=terraform /terraform /usr/local/bin
COPY --from=terraformer-all /terraformer /usr/local/bin

WORKDIR /app
COPY app .

ENTRYPOINT [ "/app/entrypoint.sh" ]
