# Terraform 

## Naming Conventions

### Общие правила

- Использовать **snake_case** для имён ресурсов и переменных.
- Имена должны быть **осмысленные и короткие**.
- Важно различать:
  - **Terraform local name** (например: `aws_s3_bucket.tf_state`)  
    → внутреннее имя в конфиге, как к нему обращаться.  
  - **AWS resource name / tag** (например: `bucket = "my-tf-state-dev"`)  
    → реально существующий объект в AWS.  

---

### Провайдеры

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

---

### Backend (state + locks)

```hcl
resource "aws_s3_bucket" "tf_state" {}
resource "aws_dynamodb_table" "tf_locks" {}

Это Terraform local names — могут быть любыми.
tf_state → для бакета, где хранится terraform.tfstate.
tf_locks → для DynamoDB таблицы блокировок.
```

---

### Сеть (VPC)

```hcl
resource "aws_vpc" "main" {}
resource "aws_subnet" "public_a" {}
resource "aws_subnet" "public_b" {}
resource "aws_internet_gateway" "igw" {}
resource "aws_route_table" "public" {}
```

- main или primary для основной VPC.
- Сети и таблицы маршрутов: public_a, private_b.
- IGW всегда igw, NAT — nat_a, nat_b.

---

### Compute (EC2)

```hcl
resource "aws_instance" "bastion" {}
resource "aws_launch_template" "app" {}
```

- Имя = роль сервера: bastion, web, db.
- Для групп: asg_web, asg_worker.

### Балансировщики (LB)

```hcl
resource "aws_lb" "public" {}
resource "aws_lb_target_group" "api" {}
```

- LB: public, internal.
- TG: api, web, default.

### Базы данных

```hcl
resource "aws_db_instance" "main" {}
resource "aws_elasticache_cluster" "redis" {}
```

- Имя = тип: main, replica, redis.

### IAM

```hcl
resource "aws_iam_role" "ec2_role" {}
resource "aws_iam_policy" "s3_access" {}
resource "aws_iam_user" "ci_user" {}
```

- Роль = <service>_role (например: ec2_role, eks_role).
- Политики: s3_access, admin_policy.
- Пользователи: ci_user, deploy_bot.

### Outputs

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
output "subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}
```

- Имена output совпадают с сущностью: vpc_id, subnet_ids, bastion_ip.

### Переменные

```hcl
variable "aws_region" {}
variable "project_name" {}
variable "env" {}
```

- Всегда маленькие буквы, snake_case.

### Популярные переменные

```hcl
env (dev, stage, prod)
project_name
aws_region
aws_profile
```

### Рекомендации

Внутренние Terraform-имена (aws_vpc.main) → короткие, без env.
Реальные AWS-имена (tags / name) → с префиксами проекта и окружения:

```hcl
"${var.project_name}-${var.env}-vpc"
"${var.project_name}-${var.env}-bastion"
```
