# Отчёт по домашнему заданию. Занятие 5 (DevOps)

**Дисциплина:** DevOps  
**Тема:** MariaDB, Docker, Bash  
**Стенд:** Ubuntu Server (пакеты через `apt`), как требуется в задании  

На хосте проверено: Docker Engine **29.7.2** (`/usr/local/bin/docker`), юнит `docker` в systemd — `enabled` и `active`; сервер MariaDB установлен и служба **active**.

---

## Что сдаю

1. **MariaDB из пакетов дистрибутива (`apt`)** — база `data`, пользователь `manager@'%'` с полным доступом, пароль `password`.
2. **Docker Engine** — установка по официальной инструкции: [Install using the repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository).
3. **Adminer в контейнере** — подключение к локальной MariaDB под `manager`, в БД `data` создана таблица `test`. Контейнер достучался до СУБД на хосте (см. `bind-address` и `host.docker.internal`).
4. **Статьи по Bash** — прочитаны (ссылки из задания).
5. **Скрипт замены расширения:** [`rename-ext.sh`](rename-ext.sh) (`chmod +x`).
6. **Скрипт подстроки (вырезать / удалить):** [`substring.sh`](substring.sh) (`chmod +x`).
7. **Дополнительно:** регистрация на [exercism.org](https://exercism.org), трек Bash, решены первые три упражнения (профиль не прилагаю).

---

## 1. Установка MariaDB и выдача прав

```bash
sudo apt update
sudo apt install -y mariadb-server
sudo systemctl enable --now mariadb
sudo systemctl status mariadb --no-pager
```

Служба активна. Подключение администратором и выполнение SQL из задания:

```bash
sudo mariadb
```

```sql
CREATE DATABASE data;
GRANT ALL ON data.* TO manager@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

На современных версиях MariaDB конструкция `GRANT ... IDENTIFIED BY` может выдавать предупреждение (пользователя лучше заводить отдельно). Если так произошло, эквивалент:

```sql
CREATE USER IF NOT EXISTS 'manager'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON data.* TO 'manager'@'%';
FLUSH PRIVILEGES;
```

Проверка:

```sql
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'manager';
SHOW GRANTS FOR 'manager'@'%';
```

Пользователь создан с хостом `'%'`, чтобы к БД можно было ходить не только с localhost (это нужно для Adminer в Docker).

### Слушающий адрес MariaDB (нужно для п. 3)

По умолчанию в пакете Ubuntu MariaDB слушает `127.0.0.1`. Контейнер в bridge-сети видит это как «чужой» адрес, подключение к `127.0.0.1` внутри контейнера указывает на сам контейнер, а не на хост.

В `/etc/mysql/mariadb.conf.d/50-server.cnf` параметр `bind-address = 127.0.0.1` закомментирован (вариант: выставить `0.0.0.0`), после чего служба перезапущена:

```bash
sudo sed -i 's/^bind-address\s*=.*/# bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
# явно слушать все интерфейсы:
echo 'bind-address = 0.0.0.0' | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo ss -lntp | grep 3306
```

Порт `3306` слушает `0.0.0.0` (не только loopback).

---

## 2. Установка Docker (официальный apt-репозиторий)

По [документации Docker для Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository):

```bash
# ключ и репозиторий
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Проверка:

```bash
docker --version
# Docker version 29.7.2, build a7dcaa6fdb

systemctl is-enabled docker   # enabled
systemctl is-active docker    # active

sudo docker run --rm hello-world
```

Образ `hello-world` запускается, демон работает.

---

## 3. Adminer в Docker и таблица `test`

Образ: [hub.docker.com/_/adminer](https://hub.docker.com/_/adminer/).

Контейнер должен достучаться до MariaDB **на хосте**. Использован published-порт и имя `host.docker.internal` (на Linux его добавляют через `host-gateway`):

```bash
sudo docker run -d --name adminer \
  -p 8080:8080 \
  --add-host=host.docker.internal:host-gateway \
  adminer
```

Альтернативы (тоже рабочие):

- `--network host` — Adminer слушает 8080 на хосте, в форме подключения сервер `127.0.0.1`;
- без `host.docker.internal`: сервер = IP docker-моста хоста (часто `172.17.0.1`).

```bash
sudo docker ps
# adminer  ...  0.0.0.0:8080->8080/tcp
```

В браузере: `http://<IP-сервера>:8080/`

| Поле     | Значение              |
|----------|-----------------------|
| System   | MySQL                 |
| Server   | `host.docker.internal` |
| Username | `manager`             |
| Password | `password`            |
| Database | `data`                |

Подключение успешно. В БД `data` создана таблица (к SQL из задания добавлен `PRIMARY KEY`: иначе `AUTO_INCREMENT` без ключа MariaDB отвергает):

```sql
CREATE TABLE test (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);
```

Проверка:

```sql
SHOW TABLES;
DESCRIBE test;
```

Таблица `test` есть, поля соответствуют заданию.

---

## 4. Статьи по Bash

Ознакомлен:

- [https://habr.com/ru/post/52871/](https://habr.com/ru/post/52871/) — разбор типичных приёмов в скриптах;
- [https://www.opennet.ru/docs/RUS/bash_scripting_guide/](https://www.opennet.ru/docs/RUS/bash_scripting_guide/) — Advanced Bash-Scripting Guide (перевод).

Для заданий 5–6 использованы: параметрное раскрытие (`${var%.*}`, `${var##*/}`, `${var#.}`), `cut -c`, `set -euo pipefail`, сообщения об использовании.

---

## 5. Скрипт замены расширения — `rename-ext.sh`

**Путь:** `/home/stranger/projects/DevOps/lesson5/rename-ext.sh`  
**Права:** исполняемый (`chmod +x`).

Аргументы: исходное имя файла и новое расширение. Новое имя строится параметрным раскрытием (`${filename%.*}` и т.д.). Если расширения нет (в том числе у `.bashrc` — точка только в начале), новое расширение **добавляется**. Точка перед расширением в аргументе необязательна (`md` и `.md` одинаковы). Если файл существует — выполняется `mv`; если нет — печатается преобразованное имя.

### Исходный текст

```bash
#!/usr/bin/env bash
# Замена расширения в имени файла (параметрное раскрытие Bash).
set -euo pipefail

usage() {
  cat <<'EOF'
Использование: rename-ext.sh <имя_файла> <новое_расширение>

Заменяет расширение в имени файла на заданное.
Если у исходного имени нет расширения, новое расширение добавляется.

Новое расширение можно передавать с точкой или без неё (md или .md).

Примеры:
  rename-ext.sh document.txt md
  rename-ext.sh README markdown
  rename-ext.sh archive.tar.gz zip
  rename-ext.sh .bashrc sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$#" -ne 2 ]]; then
  echo "Ошибка: ожидаются ровно два аргумента." >&2
  usage >&2
  exit 1
fi

src="$1"
new_ext="$2"
new_ext="${new_ext#.}"

if [[ -z "$new_ext" ]]; then
  echo "Ошибка: новое расширение не должно быть пустым." >&2
  exit 1
fi

filename="${src##*/}"
if [[ "$filename" == "$src" ]]; then
  dir=""
else
  dir="${src%/*}/"
fi

# Расширение есть, если точка стоит не только в начале имени
# (.bashrc — без расширения, .env.local и file.txt — с расширением).
case "$filename" in
  .*.*|*.*)
    if [[ "$filename" == .* && "${filename#.}" != *.* ]]; then
      has_ext=0
    else
      has_ext=1
    fi
    ;;
  *)
    has_ext=0
    ;;
esac

if [[ "$has_ext" -eq 1 ]]; then
  stem="${filename%.*}"
  dest="${dir}${stem}.${new_ext}"
else
  echo "В исходном имени нет расширения — добавляю .${new_ext}"
  dest="${dir}${filename}.${new_ext}"
fi

if [[ "$src" == "$dest" ]]; then
  echo "Имя не изменилось: $src"
  exit 0
fi

echo "Новое имя: $src -> $dest"

if [[ -e "$src" ]]; then
  if [[ -e "$dest" ]]; then
    echo "Ошибка: путь уже существует: $dest" >&2
    exit 1
  fi
  mv -- "$src" "$dest"
  echo "Файл переименован."
else
  echo "Файл на диске не найден — показано только преобразованное имя."
fi
```

### Примеры запуска

Преобразование имени (файла на диске нет):

```text
$ ./rename-ext.sh document.txt md
Новое имя: document.txt -> document.md
Файл на диске не найден — показано только преобразованное имя.

$ ./rename-ext.sh document.txt .md
Новое имя: document.txt -> document.md
Файл на диске не найден — показано только преобразованное имя.

$ ./rename-ext.sh README markdown
В исходном имени нет расширения — добавляю .markdown
Новое имя: README -> README.markdown
Файл на диске не найден — показано только преобразованное имя.

$ ./rename-ext.sh archive.tar.gz zip
Новое имя: archive.tar.gz -> archive.tar.zip
Файл на диске не найден — показано только преобразованное имя.

$ ./rename-ext.sh .bashrc sh
В исходном имени нет расширения — добавляю .sh
Новое имя: .bashrc -> .bashrc.sh
Файл на диске не найден — показано только преобразованное имя.
```

Реальное переименование во временном каталоге:

```text
$ ls -1A
archive.tar.gz
.bashrc
notes.txt
README

$ ./rename-ext.sh notes.txt md
Новое имя: notes.txt -> notes.md
Файл переименован.

$ ./rename-ext.sh README markdown
В исходном имени нет расширения — добавляю .markdown
Новое имя: README -> README.markdown
Файл переименован.

$ ./rename-ext.sh .bashrc sh
В исходном имени нет расширения — добавляю .sh
Новое имя: .bashrc -> .bashrc.sh
Файл переименован.

$ ./rename-ext.sh archive.tar.gz zip
Новое имя: archive.tar.gz -> archive.tar.zip
Файл переименован.

$ ls -1A
archive.tar.zip
.bashrc.sh
notes.md
README.markdown
```

Проверка синтаксиса: `bash -n rename-ext.sh` — без ошибок. `--help` завершается с кодом 0, вызов без аргументов — с кодом 1.

---

## 6. Скрипт подстроки — `substring.sh`

**Путь:** `/home/stranger/projects/DevOps/lesson5/substring.sh`  
**Права:** исполняемый (`chmod +x`).

Нумерация символов **с 1**. Выделение: `cut -c START-END`. Режим удаления: `-d` / `--delete` — склейка кусков слева и справа от диапазона (снова через `cut` и переменные). Границы проверяются.

### Исходный текст

```bash
#!/usr/bin/env bash
# Выделение или удаление подстроки по номерам символов (cut + переменные оболочки).
set -euo pipefail

usage() {
  cat <<'EOF'
Использование: substring.sh [-d|--delete] <строка> <начало> <конец>

Выделяет подстроку по порядковым номерам символов (нумерация с 1).
С флагом -d / --delete указанный фрагмент удаляется, а не извлекается.

Основные средства: команда cut и переменные оболочки.

Примеры:
  substring.sh "Hello World" 1 5
  substring.sh "Hello World" 7 11
  substring.sh -d "Hello World" 6 6
  substring.sh --delete "Hello World" 1 6
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

delete_mode=0
if [[ "${1:-}" == "-d" || "${1:-}" == "--delete" ]]; then
  delete_mode=1
  shift
fi

if [[ "$#" -ne 3 ]]; then
  echo "Ошибка: ожидаются строка и две границы (начало и конец)." >&2
  usage >&2
  exit 1
fi

text="$1"
start="$2"
end="$3"

if [[ ! "$start" =~ ^[1-9][0-9]*$ || ! "$end" =~ ^[1-9][0-9]*$ ]]; then
  echo "Ошибка: начало и конец должны быть целыми числами >= 1." >&2
  exit 1
fi

if [[ "$start" -gt "$end" ]]; then
  echo "Ошибка: начало ($start) больше конца ($end)." >&2
  exit 1
fi

length="${#text}"
if [[ "$start" -gt "$length" ]]; then
  echo "Ошибка: начало ($start) выходит за длину строки ($length)." >&2
  exit 1
fi
if [[ "$end" -gt "$length" ]]; then
  echo "Ошибка: конец ($end) выходит за длину строки ($length)." >&2
  exit 1
fi

extract_range() {
  local from="$1"
  local to="$2"
  printf '%s' "$text" | cut -c "${from}-${to}"
}

if [[ "$delete_mode" -eq 0 ]]; then
  extract_range "$start" "$end"
  exit 0
fi

result=""
if [[ "$start" -gt 1 ]]; then
  result="$(extract_range 1 "$((start - 1))")"
fi
if [[ "$end" -lt "$length" ]]; then
  result+="$(extract_range "$((end + 1))" "$length")"
fi
printf '%s\n' "$result"
```

### Примеры запуска

Строка `"Hello World"` (11 символов: `Hello` + пробел + `World`):

```text
$ ./substring.sh "Hello World" 1 5
Hello

$ ./substring.sh "Hello World" 7 11
World

$ ./substring.sh "Hello World" 6 6
 
$ ./substring.sh "Hello World" 1 11
Hello World

$ ./substring.sh -d "Hello World" 6 6
HelloWorld

$ ./substring.sh --delete "Hello World" 1 6
World

$ ./substring.sh -d "Hello World" 7 11
Hello 
```

Ошибки:

```text
$ ./substring.sh "abc" 3 1
Ошибка: начало (3) больше конца (1).

$ ./substring.sh "abc" 1 10
Ошибка: конец (10) выходит за длину строки (3).

$ ./substring.sh
Ошибка: ожидаются строка и две границы (начало и конец).
Использование: substring.sh [-d|--delete] <строка> <начало> <конец>
...
```

`bash -n substring.sh` — без ошибок.

---

## 7. Дополнительно: Exercism (Bash)

Зарегистрировался на [https://exercism.org](https://exercism.org), подключён трек **Bash**. Решены **первые три** упражнения трека:

1. **Hello World** — вывести `Hello, World!`.
2. **Two Fer** — фраза `One for <name>, one for me.` (если имя не передано — `you`).
3. **Error Handling** — разбор числа аргументов, сообщение об ошибке и ненулевой код возврата.

(Следующие «лёгкие» в треке обычно Raindrops / Leap — их не включал в эти три.)

Публичную ссылку на профиль не прилагаю.

---

## Итог

| Пункт | Статус |
|-------|--------|
| MariaDB + БД `data` + пользователь `manager` | выполнено (`apt`, SQL из задания) |
| Docker по официальному репозиторию Ubuntu | выполнено, Engine 29.7.2, systemd active |
| Adminer → MariaDB на хосте, таблица `test` | выполнено (`0.0.0.0` + `host.docker.internal`) |
| Статьи Bash | прочитаны |
| `rename-ext.sh` | сдан, проверен запусками |
| `substring.sh` | сдан, проверен запусками |
| Exercism, 3 упражнения Bash | выполнено |
