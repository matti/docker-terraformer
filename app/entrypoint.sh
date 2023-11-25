#!/usr/bin/env bash
set -eEuo pipefail

_on_error() {
  trap '' ERR
  line_path=$(caller)
  line=${line_path% *}
  path=${line_path#* }

  echo ""
  echo "ERR $path:$line $BASH_COMMAND exited with $1"
  _shutdown 1
}
trap '_on_error $?' ERR

_shutdown() {
  trap '' TERM INT
  echo "shutdown: $1"

  kill 0
  wait
  exit "$1"
}
trap '_shutdown 0' TERM INT

mkdir "$HOME/.aws"

echo """
[terraformer]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
""" > "$HOME/.aws/credentials"

mkdir /work || echo "work dir already exists"

echo """
provider "aws" {}
""" > /work/terraform.tf

cd /work
terraform init

terraformer import aws --profile=terraformer \
  --resources="${TERRAFORMER_RESOURCES:-*}" \
  --excludes="${TERRAFORMER_EXCLUDES:-}" \
  --retry-number 3 --retry-sleep-ms 100

cd /work/generated/aws
for dir in */; do
  cd $dir
    for f in *.tf
    do
      case "$f" in
        provider.tf|outputs.tf|variables.tf)
          :
        ;;
        *)
          cp "$f" /work/generated/aws
        ;;
      esac
    done
  cd ..
done

echo ""
echo "DONE see generated/aws/*.tf"

tail -f /dev/null & wait
