# Отчёт по домашнему заданию №11 — Git (урок 2)

**Студент:** Александр Мажуль  
**GitHub:** [aleksandr-mazhul](https://github.com/aleksandr-mazhul)  
**Занятие:** Урок 2 (в PDF задание названо «Домашнее задание №11»)

---

## Что сдаю

Три репозитория на GitHub (HTTPS — их прошу принять как сдачу работы):

1. **Задание 1** (сайт `wild_animals`): https://github.com/aleksandr-mazhul/l2-task1  
2. **Задание 2** (форк `geometric_lib` со всеми ветками): https://github.com/aleksandr-mazhul/l2-task2  
   Оригинал (upstream): https://github.com/smartiqaorg/geometric_lib  
3. **Задание 3** (опционально, практика из курса Git): https://github.com/aleksandr-mazhul/l2-task3

В методичке для задания 1 просили приватный репозиторий с именем `tms-git`. Работа выполнена полностью, но сдаю её в репозитории **`l2-task1`** (публичный): то же содержимое — `index.html` и папка `pictures/`, два коммита. Имя `tms-git` не использовал.

Других Git-URL в работе нет.

---

## Задание 1. GitHub, локальный Git, коммиты сайта wild_animals

### 1. Регистрация на GitHub

Зарегистрировался на [github.com](https://github.com). Аккаунт: **aleksandr-mazhul**.

### 2. Локальный пользователь Git и файл `.git/config`

Создал репозиторий, склонировал его и настроил имя и email **для текущего репозитория** (не глобально):

```bash
git config user.name "Aleksandr Mazhul"
git config user.email "map07102007@gmail.com"
```

Проверил, что `.git/config` изменился. Фрагмент конфигурации:

```ini
[remote "origin"]
	url = git@github.com:aleksandr-mazhul/l2-task1.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[user]
	name = Aleksandr Mazhul
	email = map07102007@gmail.com
```

Убедился командами:

```bash
git config --local --list
git config --get user.name
git config --get user.email
```

Результат: `Aleksandr Mazhul` / `map07102007@gmail.com`. Remote только один — `origin` на мой репозиторий `l2-task1`.

### 3–4. Репозиторий и клонирование

В задании: создать приватный репозиторий `tms-git` и склонировать его.

Фактически создал репозиторий **`l2-task1`** и склонировал его:

```bash
git clone git@github.com:aleksandr-mazhul/l2-task1.git
cd l2-task1
```

Содержимое задания (отслеживание `wild_animals`, два коммита) выполнено в этом репозитории.

### 5–6. Архив wild_animals

Скачал архив по ссылке из методички:

```text
https://drive.google.com/uc?export=download&confirm=no_antivirus&id=1B_b5mg7rRSKSNqwuDb1hGVYQQpHsEc1J
```

Распаковал архив. В рабочей копии оказались файлы сайта `wild_animals`:

- `index.html`
- `pictures/elephant.jpg`
- `pictures/giraffe.jpg`
- `pictures/paw_print.jpg`

### 7. Первый коммит

Сделал файлы отслеживаемыми и закоммитил:

```bash
git add index.html pictures/
git status
git commit -m "initial commit"
git rev-parse HEAD
git log --oneline
```

**Хеш первого коммита:** `fb7e4bb07573175901c7645a59cedeca5d0104e7` (короткий: `fb7e4bb`).

По ходу смотрел, как Git хранит данные:

- **`.git/index`** — индекс (staging area). После `git add` в нём появились записи о четырёх файлах. Сейчас это Git index version 2, 4 entries.
- **`.git/objects`** — объектная база. После коммита объект коммита лежит по пути  
  `.git/objects/fb/7e4bb07573175901c7645a59cedeca5d0104e7`.

Проверка типа объекта:

```bash
git cat-file -t fb7e4bb
# commit
```

### 8. Второй коммит — опечатка Elephant

В `index.html` в заголовке было написано `Elehant` вместо `Elephant`. Исправил, добавил в индекс и закоммитил:

```bash
# правка index.html: Elehant → Elephant
git add index.html
git commit -m "fix mistake in word 'Elephant'"
git log --oneline
```

**Хеш второго коммита:** `90f050b788820b314cb75b4e819440a9384672e1` (короткий: `90f050b`).

Объект коммита: `.git/objects/90/f050b788820b314cb75b4e819440a9384672e1`.

Дифф (как в истории):

```diff
-    <h2>Elehant</h2>
+    <h2>Elephant</h2>
```

История `main`:

```text
90f050b (HEAD -> main, origin/main) fix mistake in word 'Elephant'
fb7e4bb initial commit
```

Отправил на GitHub:

```bash
git push origin main
```

Репозиторий для проверки: https://github.com/aleksandr-mazhul/l2-task1

---

## Задание 2. Репозиторий geometric_lib: ветки, revert, squash, experiment

Исходный репозиторий курса: https://github.com/smartiqaorg/geometric_lib  
Мой форк (сдача): https://github.com/aleksandr-mazhul/l2-task2

### Форк со всеми ветками

Перед работой сделал **Fork** оригинала. В форме создания форка **снял галочку** «Copy the main branch only», чтобы скопировались все ветки (`main`, `develop`, `feature`, `release`), а не только `main`. После создания форка в выпадающем списке веток на GitHub они все видны.

### 1.1. Клонирование и локальные ветки

В методичке клонирование задано так:

```bash
git clone https://github.com/smartiqaorg/geometric_lib
cd geometric_lib
```

После клонирования локально есть только `main`. Остальные ветки создал checkout’ом (по заданию — отдельно `feature` и `develop`):

```bash
git checkout feature
git checkout develop
```

Чтобы иметь полный набор как в форке, также выписал `release`. Свой форк — remote `origin` (`aleksandr-mazhul/l2-task2`). Для сверки с оригиналом добавлен remote `upstream` на `smartiqaorg/geometric_lib` (других remote нет):

```bash
git remote -v
```

```text
origin    git@github.com:aleksandr-mazhul/l2-task2.git
upstream  git@github.com:smartiqaorg/geometric_lib.git
```

Локальные и `origin`-ветки сейчас: `main`, `develop`, `feature`, `experiment`, `release`.

### 1.2. Полный граф истории

Смотрел структуру коммитов командой:

```bash
git log --graph --all --oneline --decorate
```

После выполнения пунктов 2–4 граф в моём репозитории выглядит так (это актуальная история для проверки):

```text
* 04f5786 (origin/experiment, experiment) remoove circle.py and square.py
* 08c7c01 restore the calculate.py file and update docs in tasd 4.3
| * 7e6d286 (origin/develop, develop) обьеденил два комита в один
| | * 1b4e409 (origin/feature, feature) Revert "L-04: Add rectangle.py"
| | * 3049431 (upstream/feature) L-04: Add rectangle.py
| |/
|/|
| | * 86edb1c (upstream/release, origin/release, release) L-05: Update Docs. Add user agreement info
| | * 438b89a L-05: Add user agreement
| | * 6adb962 L-03: Docs added
| | | * b5b0fae (upstream/develop) L-04: Update docs for calculate.py
| | | * d76db2a L-04: Add calculate.py
| | |/
| |/|
| * | 51c40eb L-04: Doc updated for triangle
| * | d080c78 L-04: Triangle added
|/ /
* / d078c8d (HEAD -> main, upstream/main, origin/main) L-03: Docs added
|/
* 8ba9aeb L-03: Circle and square added
```

Кратко, что на графе видно:

- `main` — `d078c8d` («L-03: Docs added»), совпадает с оригиналом.
- `feature` — поверх неудачного `3049431` мой revert `1b4e409`.
- `develop` — вместо двух коммитов L-04 про `calculate.py` один squash `7e6d286`. На `upstream/develop` по-прежнему лежат исходные `d76db2a` и `b5b0fae` (оригинал я не менял).
- `experiment` — ответвление от `main`, два моих коммита (`08c7c01`, `04f5786`).
- `release` — линия курса с user agreement, без моих правок.

### 2. Ветка feature — откат последнего неудачного коммита

Последний коммит на `feature` — `30494317cde4419be779c14306561e0eaa78b88b` («L-04: Add rectangle.py»). В нём ошибка; откатил его через `git revert` (история сохранилась, поверх появился обратный коммит):

```bash
git checkout feature
git revert HEAD
# это откат коммита 30494317cde4419be779c14306561e0eaa78b88b
git push origin feature
```

Получился коммит:

- хеш: `1b4e4099edb666c6567b0458e997640dbc2f756b` (`1b4e409`)
- сообщение: `Revert "L-04: Add rectangle.py"`
- в теле: `This reverts commit 30494317cde4419be779c14306561e0eaa78b88b.`
- изменение: удалён `rectangle.py` (7 строк).

На `origin/feature` сейчас `1b4e409`. На `upstream/feature` по-прежнему «плохой» `3049431`.

### 3. Ветка develop — squash двух коммитов L-04

На `develop` были два коммита одной темы:

- `d76db2a` — `L-04: Add calculate.py`
- `b5b0fae` — `L-04: Update docs for calculate.py`

Объединил их в один через интерактивный rebase:

```bash
git checkout develop
git rebase -i HEAD~2
```

В редакторе: первый коммит `pick`, второй — `squash` (склеить с предыдущим). Новое сообщение:

```text
обьеденил два комита в один
```

Результат:

- хеш: `7e6d2861d4130a1d6ecd216c037c4065a5ee58fb` (`7e6d286`)
- родитель: `51c40eb` («L-04: Doc updated for triangle») — как и у первого из двух исходных коммитов
- в одном коммите и `calculate.py`, и обновление `docs/README.md`

```bash
git push origin develop
```

### 4. Ветка experiment (от main): calculate.py, docs, удаление circle/square

#### 4.1. Создание ветки experiment

Ветка должна начинаться с конца `main`:

```bash
git checkout main
git checkout -b experiment
```

База: `d078c8d` («L-03: Docs added»).

#### 4.2–4.3. Документация и calculate.py из develop

Актуальные `docs/README.md` и `calculate.py` взял из последнего коммита `develop` (указатель `develop` — это и есть его HEAD, после squash это `7e6d286`):

```bash
git checkout develop -- docs/README.md
git checkout develop -- calculate.py
```

#### 4.4. Индекс и коммит

```bash
git add docs/README.md calculate.py
git commit -m "restore the calculate.py file and update docs in tasd 4.3"
```

Коммит: `08c7c01aab2833cff14acf0999e173e87a206b6d` (`08c7c01`).  
В нём: добавлен `calculate.py`, обновлён `docs/README.md`.

#### 4.5. Удаление circle.py и square.py

```bash
git rm circle.py square.py
git commit -m "remoove circle.py and square.py"
git push origin experiment
```

Коммит: `04f57862ddb82b1137d3f33b968c604f0310be42` (`04f5786`).  
Удалены `circle.py` и `square.py`.

Состав ветки `experiment` сейчас: только `calculate.py` и `docs/README.md`.

---

## Задание 3 (опционально). Курс Git, урок 5

Ознакомился с материалом и выполнил практику в конце статьи:

https://smartiqa.ru/courses/git/lesson-5#theory

Сдача: https://github.com/aleksandr-mazhul/l2-task3  

Remote только `origin` (`git@github.com:aleksandr-mazhul/l2-task3.git`). Ветки: `develop`, `feature`, `main`, `release`.

На `develop` есть работа курса по треугольнику и калькулятору (`triangle.py`, `calculate.py`, коммиты `d080c78`, `51c40eb`, `d76db2a`, `b5b0fae`).  
На `feature` — `rectangle.py` (`3049431`).  
На `main` и `release` — коммит `67573e8` («L-05: Release updates»): в репозиторий добавлены `user_agreement.txt` и правки `docs/README.md`.

Граф:

```text
* 67573e8 (HEAD -> main, origin/release, origin/main, release) L-05: Release updates
* b5b0fae (origin/develop, develop) L-04: Update docs for calculate.py
* d76db2a L-04: Add calculate.py
* 51c40eb L-04: Doc updated for triangle
* d080c78 L-04: Triangle added
| * 3049431 (origin/feature, feature) L-04: Add rectangle.py
|/
* d078c8d L-03: Docs added
* 8ba9aeb L-03: Circle and square added
```

---

## Чеклист

**Задание 1**

- [x] Аккаунт GitHub: `aleksandr-mazhul`
- [x] Локальный user в `.git/config`: Aleksandr Mazhul / map07102007@gmail.com
- [x] Репозиторий создан и склонирован (в задании имя `tms-git`; сдаю **`l2-task1`**)
- [x] Архив скачан и распакован, файлы `wild_animals` отслеживаются
- [x] Обратил внимание на `.git/index` и `.git/objects`
- [x] 1-й коммит `fb7e4bb` — `initial commit`
- [x] 2-й коммит `90f050b` — исправление `Elehant` → `Elephant`
- [x] Ссылка: https://github.com/aleksandr-mazhul/l2-task1

**Задание 2**

- [x] Форк `geometric_lib` **со всеми ветками** (не только `main`)
- [x] Клонирование, `git checkout feature`, `git checkout develop`
- [x] Полный граф: `git log --graph --all --oneline --decorate`
- [x] `feature`: `git revert` коммита `3049431` → `1b4e409`
- [x] `develop`: squash двух L-04 (`d76db2a` + `b5b0fae`) → `7e6d286`
- [x] `experiment` от `main`; `git checkout develop --` для `docs/README.md` и `calculate.py` → `08c7c01`
- [x] `git rm circle.py square.py` → `04f5786`
- [x] Ссылка: https://github.com/aleksandr-mazhul/l2-task2

**Задание 3 (опционально)**

- [x] Материал https://smartiqa.ru/courses/git/lesson-5#theory
- [x] Практика: ветки `develop` / `feature` / `main` / `release`, triangle, calculate, user agreement
- [x] Ссылка: https://github.com/aleksandr-mazhul/l2-task3

Готово к проверке.
