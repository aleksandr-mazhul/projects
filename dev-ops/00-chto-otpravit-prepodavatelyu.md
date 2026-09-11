# Что отправить преподавателю (уроки 1–2 и 4–7)

Студент: **Александр Мажуль**  
GitLab: `map07102007` · GitHub: `aleksandr-mazhul`

Ниже — готовый пакет сдачи. Полные отчёты лежат в папках уроков (`hw01-report.md` … `hw07-report.md`). В чат/письмо достаточно вставить этот файл целиком или блоки по занятиям.

---

## Урок 1 / ДЗ №1 — GitLab, три коммита

**Ссылка:** https://gitlab.com/map07102007/devops

**Файл отчёта:** [lesson1/reports/hw01-report.md](lesson1/reports/hw01-report.md)

История `main`:

| Коммит | Как сделан |
|--------|------------|
| `5591d4e` Add README | веб-интерфейс GitLab |
| `924b2da` This commit was created from Cursor. | IDE (Cursor / VS Code) |
| `32afa6a` commit from terminal | терминал Linux |

---

## Урок 2 / ДЗ №11 — GitHub, форк, ветки

**Ссылки:**

1. Задание 1 (`wild_animals`, вместо имени `tms-git`): https://github.com/aleksandr-mazhul/l2-task1
2. Задание 2 (форк `geometric_lib` со всеми ветками): https://github.com/aleksandr-mazhul/l2-task2  
   Upstream: https://github.com/smartiqaorg/geometric_lib
3. Задание 3 (опционально): https://github.com/aleksandr-mazhul/l2-task3

**Файл отчёта:** [lesson2/reports/hw02-report.md](lesson2/reports/hw02-report.md)

---

## Урок 4 / ДЗ №3 — Netplan и SSH

Репозитория нет. Сдача — отчёт с конфигами Netplan (DHCP и static) и `sshd_config` (порт 2222):

**Файл:** [lesson4/reports/hw04-report.md](lesson4/reports/hw04-report.md)

---

## Урок 5 — MariaDB, Docker, Bash

**Файл отчёта:** [lesson5/reports/hw05-report.md](lesson5/reports/hw05-report.md)

**Вложения (скрипты):**

- [lesson5/completed/rename-ext.sh](lesson5/completed/rename-ext.sh) — замена расширения
- [lesson5/completed/substring.sh](lesson5/completed/substring.sh) — выделение / удаление подстроки (`cut`)

---

## Урок 6 — cron, systemd, rsyslog, logrotate

**Файл отчёта:** [lesson6/reports/hw06-report.md](lesson6/reports/hw06-report.md)

**Вложения:**

| Что просили | Файл |
|-------------|------|
| `/etc/cron.daily/` или crontab | [lesson6/completed/apt-clean](lesson6/completed/apt-clean), [lesson6/completed/crontab-line.txt](lesson6/completed/crontab-line.txt) |
| systemd unit | [lesson6/completed/myapp.service](lesson6/completed/myapp.service) |
| приложение | [lesson6/completed/index.js](lesson6/completed/index.js) |
| rsyslog | [lesson6/completed/rsyslog-myapp.conf](lesson6/completed/rsyslog-myapp.conf) |
| logrotate | [lesson6/completed/logrotate-myapp](lesson6/completed/logrotate-myapp), [lesson6/completed/logrotate-hourly](lesson6/completed/logrotate-hourly) |
| `systemctl status myapp` | [lesson6/completed/systemctl-status-myapp.txt](lesson6/completed/systemctl-status-myapp.txt) |

---

## Урок 7 / ДЗ №6 — тест по сетям и OSI

Репозитория нет. Сдача — ответы на 11 вопросов.

**Файл:** [lesson7/reports/hw07-report.md](lesson7/reports/hw07-report.md)

**Ключ:** 1 — A, B, C; 2 — A; 3 — B; 4 — B; 5 — A; 6 — D; 7 — A; 8 — A; 9 — B; 10 — C; 11 — D.
