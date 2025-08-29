### Ключевые блоки:
```
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

### Примеры кода:
#### Общий root.hcl из родительских папок (корневой aws/root.hcl)
```
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