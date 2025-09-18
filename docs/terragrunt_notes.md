# terragrunt

## research notes

### Ключевые блоки

```hcl
Terragrunt locals  ──┐
                     ├─> inputs {...}  ────────┐
или generate *.auto.tfvars ────────────────────┤
                                               ├─> Terraform variables ("variable ...")
Корневой remote_state (bucket/region/...)  ────┘
Дочерний remote_state override → key (путь к state)
```

---

- include — подтянуть корневой terragrunt.hcl.
- remote_state — один раз настроить S3+DynamoDB.
- generate — сгенерировать providers.tf, variables.tf, main.tf.
- inputs — значения переменных модуля.
- dependency — получить outputs из других стеков (межмодульные связи).

### Remote State

- State хранится в **S3 бакете**: `my-tf-state-<инициалы>`.
- Для блокировок используется **DynamoDB таблица**: `my-tf-locks`.
- Terragrunt автоматически управляет backend через `root.hcl`.

### Примеры кода

#### Общий root.hcl из родительских папок (корневой aws/root.hcl)

```hcl
include "root" { 
  path = find_in_parent_folders ("root.hcl")
  expose = true
}

```

:warnings: локали родителя не доступны !
expose = true   # <-- ключ к доступу к locals родителя
дочерние include "root" {}

#### Параметры окружения

```hcl
locals {
  env         = "dev"
  region      = "eu-central-1"
  profile     = "dev"
  name        = "${local.project}-${local.env}"
  ...

}
```

#### Ключ для remote state в S3 (bucket/table задаются в корневом terragrunt.hcl)

```hcl
locals {
  ...
  state_key   = "envs/${local.env}/terraform.tfstate"
}
```

#### Основной модуль - локальный modules/<module_name>/main.tf

```hcl
generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    module "vpc_lite" {
      source  = "../../../modules/<module_name>"
      name    = var.name
      cidr    = var.cidr
      azs     = var.azs
      subnets = var.subnets
    }

    output "<module_id>"     { value = module.<module_name>.<module_id> }
    output "subnet_ids" { value = module.<module_name>.subnet_ids }
  EOF
}
```

#### **VPC Lite (base-on-vpc-lite)**

Упрощённая версия для быстрого старта и безопасных экспериментов.
Модуль: modules/vpc-lite
Окружение: envs/dev/vpc-lite
Характеристики:

- Только публичные подсети (public subnets).
- Интернет-шлюз (IGW) для доступа наружу.

Техника:

- Переменные передаются через *.tfvars.
- Terragrunt без glue-кода (модуль подключается напрямую).

#### **VPC Pro (based-on-vpc-pro)**

Приближено к «реальному» продакшену (бастион, приватные ресурсы, NAT).
Модуль: modules/vpc-pro
Окружение: envs/dev/vpc-pro
Характеристики:

- Публичные + приватные подсети.
- Internet Gateway (IGW) и NAT Gateway.
- Частные маршруты для приватных подсетей.

Техника:

- Terragrunt генерирует main.tf (glue-код) с модулем и outputs.
- Определения переменных — через variables_env.tf, создаваемый Terragrunt.
- Значения переменных — через *.tfvars.

### mock_outputs в dependency

```hcl
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "vpc-000000"
    public_subnet_ids = ["subnet-111111"]
  }
}
```

dependency: «Модуль зависит от другого (../vpc)».
vpc-000000 и subnet-111111 — просто «заглушки», не существующие ресурсы.
Настоящие значения Terraform возьмёт из output модуля vpc при apply.

### Базовые команды

terragrunt run -- fmt      # привести код в порядок
terragrunt validate  # проверить синтаксис
terragrunt plan      # посмотреть, что создастся
terragrunt apply     # создать 

```bash
cd terraform/aws/envs/dev/vpc
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=dev
terragrunt init
terragrunt plan
```

### Destroy

только EC2 (bastion):

```bash
cd terraform/aws/envs/dev/bastion
terragrunt destroy
```

только VPC:

```bash
cd terraform/aws/envs/dev/vpc
terragrunt destroy
```

всё окружение целиком (и VPC, и EC2, и все зависимости):

```bash
cd terraform/aws/envs/dev
terragrunt run-all destroy
```

run-all пойдёт по всем подпапкам с terragrunt.hcl и вызовет destroy в правильном порядке.

При организации инфраструктурного окружения с использованием Terraform и Terragrunt можно не создавать его с нуля, а опираться на уже подготовленные окружения. Это означает, что процесс формирования можно строить на основе существующих конфигураций и использовать их как шаблон или фундамент для дальнейшего развёртывания и адаптации под новые задачи.