## Working Terraform notes/Заметки по работе с Terraform

### plan
- `terraform plan` показывает предполагаемые изменения.
- По умолчанию план хранится только в памяти, при `terraform apply` он считается заново.
- Чтобы зафиксировать именно тот план, что я видел, можно:
  ```bash
  terraform plan -out=plan.bin
  terraform apply plan.bin

В production пайплайнах это обязательно → гарантия, что apply соответствует утверждённому плану.

## plan & apply
В атрибутах команды запуска можно задать значение переменных
например:
```bash
terraform apply -var='aws_region=eu-central-1' -var='aws_profile=default' -var='bucket_name=my-tf-state-kb' -var='table_name=my-tf-locks'
```
При запуске неуказанные в атрибутах переменные будут запрошены интерактивно
