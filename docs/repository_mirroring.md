github to gitlab

- создать пустой репозиторий без README
- сгенерировать token, с правами write_repository
- скопировать HTTPS-URL проекта gitlab
- в github создать секреты
  - GITLAB_URL = https://gitlab.com/<group>/<project>.git
  - GITLAB_TOKEN = <PAT FROM GITLAB>
  - GIT_AUTHOR_NAME
  - GIT_AUTHOR_EMAIL

...
.github/workflows/mirror-to-gitlab.yml
...

###
- При отправке/теге/удалении GitHub Actions запускает `git push --mirror` на удалённый сервер GitLab.
- Все ветки и теги синхронизируются (включая удаления) благодаря ключу --mirror.
- Защищённые ветки в GitLab могут блокировать отправку — поэтому нужно настроить правила защиты веток.
- Зеркало синхронизирует **только данные Git** (коммиты/ветки/теги). Конфигурации задач/MR/CI не зеркалируются автоматически.
- Для ручного запуска: **Действия -> Зеркало на GitLab -> Запустить рабочий процесс**.

### как я содержу свои git remote в .ssh/config
```bash
ssh-keygen 
# ~/.ssh/id_gitlab

# .ssh/config
Host gitlab-ikb
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/id_gitlab

# in repo dir
git remote add gitlab gitlab-ikb:ikbornasovs/devops-portfolio.git
```

### в случае если чуствительные данные попали в удалённый репозиторий
!!! ВНИМАНИЕ !!! команда перезаписывает репозиторий
в моём случае это допустимо так как зеркало.

зачиска истории
```bash
python -m pip install --user git-filter-repo
git pull --all --tags
git filter-repo --force --invert-paths --path-glob '*.tfstate' --path-glob '*.tfstate.*'
git push --force --all
git push --force --tags
```