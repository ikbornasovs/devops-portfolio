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

### Multi-target mirroring
This repo mirrors to:
- GitLab: `$GITLAB_URL`
- GitHub#2: `$GITHUB2_URL`

Secrets required: `GITLAB_URL`, `GITLAB_TOKEN`, `GITHUB2_URL`, `GITHUB2_TOKEN`.
Pushes/Deletes trigger syncing of branches and tags to both targets.

Если целевой репозиторий должен получать workflow-файлы, токен обязан иметь:
fine-grained: 
- Actions: Read & write, 
- Contents: Read & write
или 
classic: 
- repo 
- workflow