# Отчёт по домашнему заданию №1 — Введение в DevOps

**Студент:** Александр Мажуль  
**Пользователь GitLab:** `map07102007`  
**Занятие:** Урок 1

---

## Что сдаю

Ссылка на публичный репозиторий (HTTPS — её прошу принять как сдачу работы):

**https://gitlab.com/map07102007/devops**

Клонирование по SSH:

```bash
git clone git@gitlab.com:map07102007/devops.git
```

Ветка: `main`.  
В репозитории три файла и три коммита — по одному на каждый требуемый способ: веб-интерфейс GitLab, IDE, терминал Linux.

---

## 1. Ознакомление со статьями

После занятия прочитал материалы из задания:

- [DevOps history](https://habr.com/ru/company/jugru/blog/573096/) — как появился DevOps, зачем сближать разработку и эксплуатацию, чем это отличается от «просто администрирования».
- [CI/CD для чайников](https://habr.com/ru/articles/895946/) — непрерывная интеграция и доставка: зачем автоматизировать сборку, тесты и выкладку, как это связано с Git.

Для себя зафиксировал: Git и удалённый репозиторий — база, на которой потом строится CI/CD (в GitLab это встроенный GitLab CI).

---

## 2. Рабочее окружение

Установил и использую:

- **Git** (Linux);
- **IDE:** Cursor (на базе VS Code). В файле `about.txt` я указал VS Code, потому что Cursor — это VS Code-совместимая среда; сам коммит сделан из Cursor (это видно по сообщению коммита).

Также смотрел сравнительную таблицу из задания (VS Code vs IntelliJ IDEA): для DevOps-сценариев (конфиги, скрипты, Git, терминал) мне достаточно Cursor / VS Code, полноценный IntelliJ не ставил.

---

## 3. Аккаунт GitLab

Создал аккаунт:

- логин: **map07102007**
- платформа: **GitLab.com** (не GitHub и не Bitbucket — как требуется в задании).

Кратко по сравнению платформ из занятия: GitHub удобен для open source, Bitbucket — для экосистемы Atlassian, **GitLab** выбран потому, что в задании нужен именно он и потому, что у него встроенный CI/CD.

---

## 4. SSH-ключи и доступ к GitLab

Сгенерировал пару ключей и добавил публичный ключ в GitLab (Settings → SSH Keys). Пример команд, которыми пользовался:

```bash
ssh-keygen -t ed25519 -C "map07102007@gmail.com"
```

Публичный ключ смотрел так:

```bash
cat ~/.ssh/id_ed25519.pub
```

Проверка подключения к GitLab по SSH:

```bash
ssh -T git@gitlab.com
```

После успешной проверки клонирование и push идут по адресу `git@gitlab.com:map07102007/devops.git` — без HTTPS и без пароля.

---

## 5. Публичный репозиторий

На GitLab создал **публичный** репозиторий:

- имя: `devops`
- видимость: Public
- SSH: `git@gitlab.com:map07102007/devops.git`
- HTTPS (ссылка для сдачи): `https://gitlab.com/map07102007/devops`

Других Git-URL в работе нет.

---

## 6–8. Три коммита: веб-интерфейс, IDE, терминал

История ветки `main` (от старого к новому):

| № | Хеш | Сообщение | Откуда сделан | Файл |
|---|------|-----------|---------------|------|
| 1 | `5591d4e` | `Add README` | **Веб-интерфейс GitLab** | `README.md` |
| 2 | `924b2da` | `This commit was created from Cursor.` | **IDE: Cursor** (файл `about.txt` говорит про VS Code) | `about.txt` |
| 3 | `32afa6a` | `commit from terminal` | **Терминал Linux** (`git` в консоли) | `terminal.txt` |

Автор коммитов: Aleksandr Mazhul `<map07102007@gmail.com>`.

### Коммит 1 — веб-интерфейс GitLab (`5591d4e`)

Сделал **первый коммит прямо в браузере** на gitlab.com: создал файл `README.md` через UI (Add README / Web IDE / редактор файла на сайте — без локального `git commit`).

Содержимое `README.md`:

```markdown
# DevOps

Laboratory work №1

Author: Aleksandr Mazhul
```

Сообщение коммита: `Add README`.  
Дата: 4 августа 2026, 15:43 UTC.

Это единственный коммит, который **не** создавался локально командой `git commit`.

### Коммит 2 — из IDE Cursor (`924b2da`)

Репозиторий **клонировал в IDE по SSH**:

```bash
git clone git@gitlab.com:map07102007/devops.git
```

Дальше работал в **Cursor** (VS Code-совместимая IDE): добавил файл `about.txt` с текстом:

```text
This commit was created from VS Code.
```

Коммит и отправка:

```bash
git add about.txt
git commit -m "This commit was created from Cursor."
git push origin main
```

- **IDE, из которой сделан второй коммит:** Cursor.  
- В тексте файла указан VS Code — это та же линейка редакторов; название IDE для проверки задания — **Cursor**.

Хеш: `924b2da`. Дата: 4 августа 2026, 18:48 +0300.

### Коммит 3 — из терминала Linux (`32afa6a`)

Отдельно **клонировал репозиторий в консоли Linux** той же SSH-командой `git clone`:

```bash
git clone git@gitlab.com:map07102007/devops.git
```

В каталоге репозитория создал `terminal.txt`:

```text
This file was created from the Linux terminal.
```

Третий коммит — **только из терминала**, командами git (не из IDE):

```bash
git add terminal.txt
git commit -m "commit from terminal"
git push origin main
```

Хеш: `32afa6a`. Дата: 4 августа 2026, 18:50 +0300.

В формулировке задания для третьего пункта стоит «указать, из какой именно IDE» — это, судя по контексту, копипаст с пункта про IDE. Третий коммит сделан **не из IDE**, а из **Linux-терминала**.

---

## 9. Ссылка на репозиторий

Ещё раз ссылка для проверки:

**https://gitlab.com/map07102007/devops**

Проверить историю можно так:

```bash
git clone git@gitlab.com:map07102007/devops.git
cd devops
git log --oneline
```

Ожидаемый вывод (новые сверху):

```text
32afa6a commit from terminal
924b2da This commit was created from Cursor.
5591d4e Add README
```

Файлы в корне:

- `README.md` — веб-UI GitLab;
- `about.txt` — Cursor / VS Code;
- `terminal.txt` — терминал Linux.

---

## Чеклист задания

- [x] Прочитаны статьи Habr (история DevOps, CI/CD)
- [x] Установлены Git и IDE (Cursor / VS Code)
- [x] Создан аккаунт GitLab (`map07102007`)
- [x] Сгенерированы SSH-ключи, настроено подключение `ssh -T git@gitlab.com`
- [x] Создан **публичный** репозиторий `devops`
- [x] Один коммит через **веб-интерфейс GitLab** — `5591d4e` (`Add README`)
- [x] Репозиторий клонирован в IDE **по SSH**, второй коммит **из Cursor** — `924b2da`
- [x] Репозиторий клонирован в **консоли Linux** командой `git` **по SSH**, третий коммит **из терминала** — `32afa6a`
- [x] Ссылка на репозиторий: https://gitlab.com/map07102007/devops

Готово к проверке.
