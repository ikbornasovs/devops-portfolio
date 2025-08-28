при попытке пушить изменения, получил ошибку
```
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

из коммита нужно удалить кэш 
```
sudo apt install git-filter-repo
git filter-repo --path terraform/aws/bootstrap-backed/.terraform --invert-paths
```
! будет предупреждение, в этот раз игнорировать, так как в origin нет этой ветки.
```
git filter-repo --path terraform/aws/bootstrap-backed/.terraform --invert-paths --force
git push --force-with-lease origin learning_terraform
```

после форсированной очистки удалились и remote, добавляем:
```
git remote -v
git remote add origin github-ikb:ikbornasovs/devops-portfolio.git
git remote -v
git push --force-with-lease origin learning_terraform
```