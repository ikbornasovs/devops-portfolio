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
- 