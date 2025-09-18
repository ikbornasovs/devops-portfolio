# GIT

## research notes

Совершил push в main, при том что был уже PR из test в main
в PR по такому поводу появились конфликты

Отменить лишние коммиты в main с помощью git revert
затем подтягиваем чистый main в ветку test — конфликты исчезнут.

Найти диапазон «случайных» коммитов в main

```bash
git switch main
git fetch origin
git log --oneline --decorate --graph origin/main
```

В выводе нужно запомнить хеши от <BAD_OLDEST> .. <BAD_LATEST>
Отменить эти коммиты в main одним или несколькими revert
Создаст обратные коммиты:

```bash
git revert <BAD_OLDEST>^..<BAD_LATEST>
```

В том случае если будут конфликты, придётся их решить.

```bash
git add -A
git commit
git push origin main
```

Теперь можно обновить ветку test поверх исправленного main

```bash
git switch test
git fetch origin
git merge origin/main     
# или git rebase origin/main
# решить конфликты если будут
git add -A
git commit
git push origin test
```

PR test в main снова станет «mergeable».
