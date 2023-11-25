# terraformer that works

`.env` with

```console
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
TERRAFORMER_RESOURCES=*
TERRAFORMER_EXCLUDES=identitystore,something
```

`docker compose up --build --force-recreate`

## cleanup stuff

`docker compose exec terraformer bash`

```console
cd /work/generated/aws/alb
terraform state replace-provider registry.terraform.io/-/aws hashicorp/aws
terraform init
terraform destroy -auto-approve
```
