AMI best practice 
- Permission boundary для любых IAM users (если они таки есть). Ограничивай верхнюю границу разрешений.
- Политики на группу, а не навешивать пачками на каждого пользователя.
- Теги (Owner, Env, CostCenter) + условия в политиках, привязанные к тэгам.
- CloudTrail + Access Analyzer — держать включёнными, проверять лишние разрешения.
- SCP в AWS Organizations — запрещать то, что в принципе не должно выполняться (напр., root-доступ, удаление Trail, создание пользователей и т.п. в прод-аккаунтах).
- Паролей к консоли лучше избегать для ботов; если уж надо — требовать MFA, ротацию и reset at first login.

---

В AWS CLI/SDK (и, соответственно, в Terraform) “пользователь” или “роль” выбирается через профиль в файлах ~/.aws/credentials и ~/.aws/config.

1. Где хранятся профили

~/.aws/credentials → ключи (AccessKey + SecretKey).
~/.aws/config → регионы, SSO, AssumeRole и т.д.

2. Как выглядят профили
Статический пользователь (IAM user с ключами)

~/.aws/credentials
[dev]
aws_access_key_id = AKIA....
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/...

~/.aws/config

[profile dev]
region = eu-central-1


Использование:

AWS_PROFILE=dev aws sts get-caller-identity
SSO (через AWS IAM Identity Center)

~/.aws/config

[profile dev-sso]
sso_start_url = https://mycompany.awsapps.com/start
sso_region    = eu-central-1
sso_account_id = 123456789012
sso_role_name  = Developer
region = eu-central-1

Авторизация:

aws sso login --profile dev-sso
AssumeRole (подключение через роль)

~/.aws/config

[profile prod-admin]
role_arn       = arn:aws:iam::123456789012:role/Admin
source_profile = dev
region         = eu-central-1

Тут source_profile = dev — это профиль с ключами или SSO, через который роль можно “ассюмить”.

3. Как переключаться между пользователями/ролями

CLI:

AWS_PROFILE=dev aws sts get-caller-identity
AWS_PROFILE=prod-admin aws s3 ls

Terraform:
либо через -var 'aws_profile=dev',
либо в terraform.tfvars:

aws_profile = "dev"

4. Как посмотреть статус профилев
aws configure list-profiles
aws configure list --profile dev
aws sts get-caller-identity --profile dev

