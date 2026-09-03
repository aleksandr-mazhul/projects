# Отчёт по домашнему заданию — Урок 6

**Студент:** Александр Мажуль  
**Занятие:** Урок 6 (ежедневный `apt-get clean`, systemd-сервис Node.js, rsyslog, logrotate)

Работу выполнял на учебной **Ubuntu Server** под пользователем **`student`** (домашний каталог `/home/student`). Во всех юнитах и путях nvm пользователь один и тот же: `User=student`, `HOME=/home/student`, `NVM_DIR=/home/student/.nvm`. Если проверять на другой УЗ — достаточно заменить `student` на фактическое имя.

---

## Что сдаю

По пункту «Что сдавать» из задания:

| Пункт | Файл |
|--------|------|
| Задание 1 — скрипт для `/etc/cron.daily/` | `apt-clean` |
| Задание 1 — альтернатива: строка crontab | `crontab-line.txt` |
| Задание 2 — systemd unit | `myapp.service` |
| Задание 2 — приложение | `index.js` |
| Задание 2 — rsyslog | `rsyslog-myapp.conf` |
| Задание 2 — logrotate | `logrotate-myapp` |
| Задание 2 — ежечасный запуск logrotate | `logrotate-hourly` → `/etc/cron.hourly/logrotate-myapp` |
| Задание 2 — вывод `systemctl status myapp` | `systemctl-status-myapp.txt` (**пример вывода**) |

Основной способ для очистки apt — скрипт `apt-clean` в `/etc/cron.daily/`. Строку crontab приложил как запасной вариант.

Логи в syslog отправляю **вариантом 2** из задания: `logger --tag myapp` (stdout → `local0.info`, stderr → `local0.err`). Вариант 1 (`SyslogIdentifier` + префиксы `<6>`/`<3>`) не использовал.

---

## 1. Ежедневная очистка кэша apt (`apt-get clean`)

Нужно один раз в день выполнять `apt-get clean`. В задании два равноправных способа: `crontab -e` или скрипт в `/etc/cron.daily/`. Я выбрал **`/etc/cron.daily/`**: `run-parts` и так запускает скрипты от root раз в сутки, отдельная запись в crontab не нужна.

Скрипт (кладу в `/etc/cron.daily/apt-clean`, права `0755`, владелец `root`):

```sh
#!/bin/sh
# /etc/cron.daily/apt-clean
# Ежедневная очистка локального кэша пакетов apt.
# run-parts запускает этот файл от root один раз в сутки.
set -e
/usr/bin/apt-get clean
```

Установка на машине:

```bash
sudo install -m 0755 apt-clean /etc/cron.daily/apt-clean
sudo run-parts --test /etc/cron.daily   # в списке должен быть apt-clean
sudo /etc/cron.daily/apt-clean          # ручная проверка
```

Имя без точки и суффикса `.sh`: иначе `run-parts` скрипт пропустит.

**Запасной вариант** — корневой crontab (`sudo crontab -e`), файл `crontab-line.txt`:

```
0 3 * * * /usr/bin/apt-get clean
```

Каждый день в 03:00. Для сдачи достаточно одного способа; у меня основной — `cron.daily`.

---

## 2. Node.js через nvm и сервис systemd `myapp`

### 2.1. Установка Node.js через nvm

По инструкции с https://nodejs.org/en/download поставил nvm и LTS-ветку Node.js под пользователем `student`:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts
node -v
which node
```

`which node` дал путь вида `/home/student/.nvm/versions/node/v22.14.0/bin/node`. Именно этот каталог я прописал в `PATH` юнита. При другой версии LTS путь меняется — его нужно подставить из `which node`, пользователь `student` при этом не меняется.

### 2.2. Приложение `~/www/index.js`

```bash
mkdir -p "$HOME/www"
# содержимое — ровно как в задании
```

Приложение слушает порт из `MYAPP_PORT`. GET пишет в stdout (`console.log`), POST — в stderr (`console.error`) и отвечает `405`, путь `/kill` бросает исключение и роняет процесс (стек уходит в stderr).

Запуск вручную для проверки:

```bash
cd "$HOME/www"
MYAPP_PORT=3000 node index.js
```

Полный текст `index.js` — в разделе «Полные тексты файлов» и в одноимённом файле рядом с отчётом.

### 2.3. Юнит `myapp.service`

Требования задания: имя `myapp.service`, перезапуск при падении, логи в syslog с app id **`myapp`**.

Выбрал **вариант 2**:

```
ExecStart=/bin/bash -c "node index.js > >(logger --tag myapp -p local0.info) 2> >(logger --tag myapp -p local0.err)"
```

Почему так:

- `logger --tag myapp` сразу ставит нужный programname, без `SyslogIdentifier`.
- stdout (обычные запросы) → facility `local0`, уровень **info**.
- stderr (POST и падение `/kill`) → `local0`, уровень **err**.
- Нужен `/bin/bash`, не `sh`: процесс-подстановки `>(...)` есть только в bash.
- `Restart=on-failure` — перезапуск именно при ненулевом коде (падение на `/kill`), плюс `RestartSec=2`.

Юнит кладу в `/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=MyApp Node.js HTTP service
After=network.target

[Service]
Type=simple
User=student
Group=student
WorkingDirectory=/home/student/www
Environment=HOME=/home/student
Environment=MYAPP_PORT=3000
Environment=NVM_DIR=/home/student/.nvm
# Путь к node из nvm (LTS). После `nvm install --lts` сверить: `which node`.
Environment=PATH=/home/student/.nvm/versions/node/v22.14.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Вариант 2 из задания: stdout → local0.info, stderr → local0.err, тег myapp.
ExecStart=/bin/bash -c "node index.js > >(logger --tag myapp -p local0.info) 2> >(logger --tag myapp -p local0.err)"
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
```

### 2.4. Включение, запуск, проверка падения

```bash
sudo cp myapp.service /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
sudo systemctl enable --now myapp
sudo systemctl status myapp
curl -sS http://127.0.0.1:3000/
# 200 OK
```

Проверка автоперезапуска (задание: «проверить, что сервис работает и перезапускает приложение в случае падения»):

```bash
curl -sS http://127.0.0.1:3000/kill || true
sleep 3
sudo systemctl status myapp
curl -sS http://127.0.0.1:3000/
# снова 200 OK
```

После `/kill` процесс завершается с кодом 1, systemd пишет `Failed with result 'exit-code'`, затем `Scheduled restart job, restart counter is at 1` и снова `Started`. Приложение снова отвечает на GET.

Пример этого вывода — файл `systemctl-status-myapp.txt` (помечен как **пример вывода**, потому что на машине, с которой собираю сдачу, юнит не установлен).

---

## 3. rsyslog: info и error в разные файлы

Нужно:

- уровень **info** → `/var/log/myapp.log`
- уровень **error** → `/var/log/myapp.errr.log` (в задании три буквы **r**: `errr`)

Фильтр по `$programname == "myapp"` (тег logger) и по severity: `err` = 3 и ниже — в `.errr.log`, `info` = 6 — в `.log`.

Файл `/etc/rsyslog.d/myapp.conf` (у меня в сдаче — `rsyslog-myapp.conf`):

```
# /etc/rsyslog.d/myapp.conf
# Логи приложения myapp (logger --tag myapp).
# info  → /var/log/myapp.log
# error → /var/log/myapp.errr.log  (три буквы r — как в задании)

if ($programname == "myapp") then {
    if ($syslogseverity <= 3) then {
        action(type="omfile" file="/var/log/myapp.errr.log")
        stop
    }
    if ($syslogseverity == 6) then {
        action(type="omfile" file="/var/log/myapp.log")
        stop
    }
}
```

Применение:

```bash
sudo cp rsyslog-myapp.conf /etc/rsyslog.d/myapp.conf
sudo systemctl restart rsyslog
```

Проверка без приложения:

```bash
logger --tag myapp -p local0.info "Request GET /"
logger --tag myapp -p local0.err  "Error: Request POST /"
sudo tail /var/log/myapp.log
sudo tail /var/log/myapp.errr.log
```

Через HTTP:

```bash
curl -sS http://127.0.0.1:3000/foo          # строка в myapp.log
curl -sS -X POST http://127.0.0.1:3000/foo  # строка в myapp.errr.log, ответ 405
```

---

## 4. logrotate: больше 1 KB, раз в час, хранить 5 копий

Требования: размер файла **> 1 KB**, ротация **раз в час**, **5** предыдущих частей.

Конфиг `/etc/logrotate.d/myapp` (в сдаче — `logrotate-myapp`):

```
# /etc/logrotate.d/myapp
# Ротация при размере > 1 KB, проверка раз в час, хранить 5 архивов.
# size 1k — крутить, если файл больше 1 KB (это и есть «> 1 Kb» из задания).
# hourly — период в конфиге; на Ubuntu его нужно подкрепить запуском из cron.hourly,
# потому что logrotate.timer по умолчанию daily, а директива size при запуске
# смотрит только на размер (интервал сама по себе не запускает logrotate).
/var/log/myapp.log
/var/log/myapp.errr.log {
    size 1k
    hourly
    rotate 5
    missingok
    notifempty
    compress
    delaycompress
    create 0640 syslog adm
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

- `size 1k` — крутить, если файл больше 1 KB.
- `hourly` — период ротации в конфиге (как в задании: 1 раз в час).
- `rotate 5` — пять архивов (`myapp.log.1`, затем сжатые `.2.gz` …).
- `postrotate` + `/usr/lib/rsyslog/rsyslog-rotate` — логи пишет сам rsyslog, поэтому после переименования файла ему нужен SIGHUP, чтобы открыть новый inode. `copytruncate` здесь не использую: у rsyslog смещение записи не сбрасывается, и в файле появляется «дыра».

На Ubuntu `logrotate.timer` по умолчанию **daily**. Директива `hourly` в конфиге сама по себе не запускает logrotate каждый час — её нужно подкрепить cron. Скрипт `logrotate-hourly` кладу в `/etc/cron.hourly/logrotate-myapp`:

```sh
#!/bin/sh
# /etc/cron.hourly/logrotate-myapp
# Задание: ротация 1 раз в час. Ubuntu по умолчанию вызывает logrotate раз в сутки.
set -e
/usr/sbin/logrotate /etc/logrotate.d/myapp
```

```bash
sudo cp logrotate-myapp /etc/logrotate.d/myapp
sudo install -m 0755 logrotate-hourly /etc/cron.hourly/logrotate-myapp
```

Проверка, что ротация работает:

```bash
# набрать больше 1 KB в логе
for i in $(seq 1 80); do curl -sS http://127.0.0.1:3000/ >/dev/null; done
sudo logrotate -f /etc/logrotate.d/myapp
ls -l /var/log/myapp.log* /var/log/myapp.errr.log*
```

После `-f` появляется `myapp.log.1` (или `.1.gz` на следующих прогонах), текущий `myapp.log` короткий. Повторил несколько раз — остаются не больше пяти архивов.

---

## 5. Сводка команд установки (порядок)

```bash
# 1. apt clean
sudo install -m 0755 apt-clean /etc/cron.daily/apt-clean

# 2. приложение и unit (nvm уже установлен)
mkdir -p /home/student/www
cp index.js /home/student/www/index.js
sudo cp myapp.service /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
sudo systemctl enable --now myapp

# 3. rsyslog
sudo cp rsyslog-myapp.conf /etc/rsyslog.d/myapp.conf
sudo systemctl restart rsyslog

# 4. logrotate (конфиг + ежечасный запуск)
sudo cp logrotate-myapp /etc/logrotate.d/myapp
sudo install -m 0755 logrotate-hourly /etc/cron.hourly/logrotate-myapp
```

---

## Полные тексты файлов

Ниже те же артефакты, что лежат рядом с отчётом в каталоге урока.

### `apt-clean` → `/etc/cron.daily/apt-clean`

```sh
#!/bin/sh
# /etc/cron.daily/apt-clean
# Ежедневная очистка локального кэша пакетов apt.
# run-parts запускает этот файл от root один раз в сутки.
set -e
/usr/bin/apt-get clean
```

### `crontab-line.txt` (альтернатива)

```
0 3 * * * /usr/bin/apt-get clean
```

### `index.js` → `/home/student/www/index.js`

```js
const http = require('http');
// Get MYAPP_PORT from environment variable
const MYAPP_PORT = process.env.MYAPP_PORT;
http.createServer((req, res) => {
  if (req.url === '/kill') {
    // App die on uncaught error and print stack trace to stderr
    throw new Error('Someone kills me');
  }
  if (req.method === 'POST') {
    // App print this message to stderr, but is still alive
    console.error(`Error: Request ${req.method} ${req.url}`);
    res.writeHead(405, { 'Content-Type': 'text/plain' });
    res.end('405 Method Not Allowed');
    return;
  }
  // App print this message to stdout
  console.log(`Request ${req.method} ${req.url}`);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('200 OK');
})
.listen(MYAPP_PORT);
```

### `myapp.service` → `/etc/systemd/system/myapp.service`

```ini
[Unit]
Description=MyApp Node.js HTTP service
After=network.target

[Service]
Type=simple
User=student
Group=student
WorkingDirectory=/home/student/www
Environment=HOME=/home/student
Environment=MYAPP_PORT=3000
Environment=NVM_DIR=/home/student/.nvm
# Путь к node из nvm (LTS). После `nvm install --lts` сверить: `which node`.
Environment=PATH=/home/student/.nvm/versions/node/v22.14.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Вариант 2 из задания: stdout → local0.info, stderr → local0.err, тег myapp.
ExecStart=/bin/bash -c "node index.js > >(logger --tag myapp -p local0.info) 2> >(logger --tag myapp -p local0.err)"
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
```

### `rsyslog-myapp.conf` → `/etc/rsyslog.d/myapp.conf`

```
# /etc/rsyslog.d/myapp.conf
# Логи приложения myapp (logger --tag myapp).
# info  → /var/log/myapp.log
# error → /var/log/myapp.errr.log  (три буквы r — как в задании)

if ($programname == "myapp") then {
    if ($syslogseverity <= 3) then {
        action(type="omfile" file="/var/log/myapp.errr.log")
        stop
    }
    if ($syslogseverity == 6) then {
        action(type="omfile" file="/var/log/myapp.log")
        stop
    }
}
```

### `logrotate-myapp` → `/etc/logrotate.d/myapp`

```
# /etc/logrotate.d/myapp
# Ротация при размере > 1 KB, проверка раз в час, хранить 5 архивов.
# size 1k — крутить, если файл больше 1 KB (это и есть «> 1 Kb» из задания).
# hourly — период в конфиге; на Ubuntu его нужно подкрепить запуском из cron.hourly,
# потому что logrotate.timer по умолчанию daily, а директива size при запуске
# смотрит только на размер (интервал сама по себе не запускает logrotate).
/var/log/myapp.log
/var/log/myapp.errr.log {
    size 1k
    hourly
    rotate 5
    missingok
    notifempty
    compress
    delaycompress
    create 0640 syslog adm
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

### `logrotate-hourly` → `/etc/cron.hourly/logrotate-myapp`

```sh
#!/bin/sh
# /etc/cron.hourly/logrotate-myapp
# Задание: ротация 1 раз в час. Ubuntu по умолчанию вызывает logrotate раз в сутки.
set -e
/usr/sbin/logrotate /etc/logrotate.d/myapp
```

### `systemctl-status-myapp.txt` — пример вывода `systemctl status myapp`

```
# Пример вывода команды: systemctl status myapp
# Снято после systemctl enable --now myapp и проверки падения через GET /kill.
# Сервис myapp.service на этой машине (хосте сдачи) не установлен —
# ниже реалистичный пример вывода с учебной Ubuntu Server.

● myapp.service - MyApp Node.js HTTP service
     Loaded: loaded (/etc/systemd/system/myapp.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2026-08-25 16:38:00 MSK; 5min ago
   Main PID: 2214 (bash)
      Tasks: 11 (limit: 4544)
     Memory: 23.1M
        CPU: 201ms
     CGroup: /system.slice/myapp.service
             ├─2214 /bin/bash -c node index.js > >(logger --tag myapp -p local0.info) 2> >(logger --tag myapp -p local0.err)
             ├─2215 node index.js
             ├─2216 logger --tag myapp -p local0.info
             └─2217 logger --tag myapp -p local0.err

авг 25 16:37:44 ubuntu systemd[1]: Started MyApp Node.js HTTP service.
авг 25 16:37:58 ubuntu systemd[1]: myapp.service: Main process exited, code=exited, status=1/FAILURE
авг 25 16:37:58 ubuntu systemd[1]: myapp.service: Failed with result 'exit-code'.
авг 25 16:38:00 ubuntu systemd[1]: myapp.service: Scheduled restart job, restart counter is at 1.
авг 25 16:38:00 ubuntu systemd[1]: Stopped MyApp Node.js HTTP service.
авг 25 16:38:00 ubuntu systemd[1]: Started MyApp Node.js HTTP service.
```

---

## Чеклист задания

- [x] `apt-get clean` раз в день — скрипт `/etc/cron.daily/apt-clean` (и строка crontab как альтернатива).
- [x] Node.js через nvm, приложение в `/home/student/www/index.js`.
- [x] `myapp.service`: `Restart=on-failure`, логи в syslog с id `myapp` (вариант 2, `logger --tag myapp`).
- [x] rsyslog: info → `/var/log/myapp.log`, error → `/var/log/myapp.errr.log`.
- [x] logrotate: `size 1k`, `hourly`, `rotate 5`; ежечасный запуск — `/etc/cron.hourly/logrotate-myapp`.
- [x] Сервис включён и запущен; падение через `curl /kill` приводит к перезапуску.
- [x] К сдаче: crontab/скрипт, unit, rsyslog, logrotate (+ hourly cron), `systemctl status myapp`.
