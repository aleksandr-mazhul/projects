# Задание

## 1. Настроить очистку кэша apt 1 раз в день командой  `apt-get clean`

Комманда `crontab -e` или создать скрипт в `/etc/cron.daily/`

## 2. Устаноить nodejs и запустить приложение как сервис systemd, настройть отправку и ротацию логов в syslog

### Устаноить nodejs и запустить приложение как сервис systemd

1. Установить nodejs с помощью nvm по инструкции https://nodejs.org/en/download


2. Создать папку `www` в *$HOME* папке пользователя и записать приложение в файл `index.js` в этой папке.

Приложение:

```
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

Команда для запуска:

```
MYAPP_PORT=3000 node index.js
```

3. Создать systemd unit для запуска этого приложения.

  1. Юнит должен называться `myapp.service`
  2. Приложение должно презапускаться в случае падения
  3. Логи должны пересылаться в syslog c app id=myapp


<details>
<summary>Варианты решения:</summary>

1. Добавление log level в вывод программы и дальнейшая отправка в syslog самим systemd
```
ExecStart=/bin/bash -c "node index.js > >(sed -u 's/^/<6> /') 2> >(sed -u 's/^/<3> /' >&2)"
SyslogIdentifier=myapp
SyslogLevelPrefix=true
```

2. Отправка в syslog без участия systemd с помощью logger

```
ExecStart=/bin/bash -c "node index.js > >(logger --tag myapp -p local0.info) 2> >(logger --tag myapp -p local0.err)"
```

3. Смешанный вариант из ДЗ

```
ExecStart=/bin/sh -c 'node index.js | logger --tag myapp'
SyslogIdentifier=myapp
```

</details>

---
Документация 

  - https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
  - https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#

4. Включить и запустить сервис. Проверить что он работает и презапускает приложение в слуые падения.

### Настроить sysylog для записи логов приложения в файлы

  - level=info в /var/log/myapp.log
  - level=error в /var/log/myapp.errr.log

---
Статьи
 
  - Про настройку rsyslog - https://habr.com/ru/articles/321262/

Документация 
  - https://man7.org/linux/man-pages/man5/rsyslog.conf.5.html
  - https://docs.rsyslog.com/doc/

### Настроить ротацию логов для файлов /var/log/myapp.log и /var/log/myapp.errr.log

Требования:
  - размер файла > 1 Kb
  - ротация выполняется 1 раз в час 
  - хранить 5 предыдущих частей лога 

Проверить что ротация работает

---
Статьи
 
  - Про ротацию логов rsysylog - https://habr.com/ru/articles/321262/


# Что сдавать

- Задание 1 - строку из crontab или скрипт при использованиии /etc/cron.daily/
- Задание 2 - systemd unit, rsyslog конфиг, logrotate config, вывод команлы `systemctl status myapp`
