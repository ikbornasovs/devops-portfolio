# research notes

при попытке пушить изменения, получил ошибку

```bash
git push origin learning_terraform
Enumerating objects: 26, done.
Counting objects: 100% (26/26), done.
Delta compression using up to 8 threads
Compressing objects: 100% (15/15), done.
Writing objects: 100% (25/25), 141.14 MiB | 1.70 MiB/s, done.
Total 25 (delta 0), reused 1 (delta 0), pack-reused 0
remote: error: Trace: e0fe00d31f1eb54a0c53960eff9505cf4b73dcd8c5d5f61b2fd22c36fd9d097c
remote: error: See https://gh.io/lfs for more information.
remote: error: File terraform/aws/bootstrap-backed/.terraform/providers/registry.terraform.io/hashicorp/aws/5.100.0/linux_amd64/terraform-provider-aws_v5.100.0_x5 is 674.20 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
To github-ikb:ikbornasovs/devops-portfolio.git
 ! [remote rejected] learning_terraform -> learning_terraform (pre-receive hook declined)
error: failed to push some refs to 'github-ikb:ikbornasovs/devops-portfolio.git'
```

В коммит попал большой файл из директории которую не нужно коммитить ./.terraform
для этого добавляем в .gitingnore
\*\*/.terraform/\*\*

Большие файлы уже в истории

```bash
sudo apt install git-filter-repo
git filter-repo --path terraform/aws/bootstrap-backed/.terraform --invert-paths
```

! будет предупреждение, в этот раз игнорировать, так как в origin нет этой ветки.

```bash
git filter-repo --path terraform/aws/bootstrap-backed/.terraform --invert-paths --force
# **!!! ВНИМАНИЕ !!! команда перезаписывает репозиторий**
git push --force-with-lease origin branch_name
```

после форсированной очистки удалились и remote, добавляем:

```bash
git remote -v
git remote add origin github-ikb:ikbornasovs/devops-portfolio.git
git remote -v
# **!!! ВНИМАНИЕ !!! команда перезаписывает репозиторий**
git push --force-with-lease origin branch_name
```

## Error: Error acquiring the state lock

```bash
 Error message: operation error DynamoDB: PutItem, https response error
  │ StatusCode: 400, RequestID:
  │ P6MFR1L78PE3BA3NH303R136BBVV4KQNSO5AEMVJF66Q9ASUAAJG,
  │ ConditionalCheckFailedException: The conditional request failed
  │ Lock Info:
  │   ID:        166548c2-710f-a50c-7667-cd474bfde175
  │   Path:      my-tf-state-ikb/envs/dev/vpc-pro/terraform.tfstate
  │   Operation: OperationTypePlan
  │   Who:       bo@yogabo
  │   Version:   1.13.1
  │   Created:   2025-09-26 08:57:33.679025608 +0000 UTC
  │   Info:
  │
  │
  │ Terraform acquires a state lock to protect the state from being written
  │ by multiple users at the same time. Please resolve the issue above and try
  │ again. For most commands, you can disable locking with the "-lock=false"
  │ flag, but this is not recommended.
```

«залипший» лок в DynamoDB для ключа
my-tf-state-ikb/envs/dev/vpc-pro/terraform.tfstate с ID 166548c2-710f-a50c-7667-cd474bfde175.

### решение

#### чтобы backend точно совпал

```bash
aws dynamodb delete-item --table-name my-tf-locks --key '{"LockID":{"S":"my-tf-state-ikb/envs/dev/vpc-pro/terraform.tfstate"}}'
terragrunt init -reconfigure # чтобы backend точно совпал
terraform force-unlock -force 166548c2-710f-a50c-7667-cd474bfde175 # снять лок
```

далее plan

## AWS credentials

```bash
21:08:47.386 ERROR  Error finding AWS credentials (did you set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables?): operation error STS: GetCallerIdentity, get identity: get credentials: failed to refresh cached credentials, no EC2 IMDS role found, operation error ec2imds: GetMetadata, request canceled, context deadline exceeded
21:08:47.398 ERROR  Unable to determine underlying exit code, so Terragrunt will exit with error code 1
21:08:47.402 ERROR  Suggested fixes:
Missing AWS credentials. Provide credentials to proceed.
```

### решение

```bash
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=dev
```
