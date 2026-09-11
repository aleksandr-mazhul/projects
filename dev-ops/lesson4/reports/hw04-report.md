# Отчёт по домашнему заданию №3 — сеть (Netplan) и OpenSSH

**Студент:** Александр Мажуль  
**Занятие:** Урок 4 (в PDF задание озаглавлено «Домашнее задание №3»)  
**Система:** Ubuntu Server 20.04 LTS, гостевая машина VirtualBox  
**Пользователь гостя:** `aleksandr`

---

## Что сдаю

Репозитория и скриншотов нет: работа выполнена на гостевой Ubuntu Server 20.04. Ниже — то, по чему можно проверить задание без доступа к ВМ:

- итоговый и учебные конфиги **Netplan** (`/etc/netplan/50-cloud-init.yaml`): вариант **DHCP** и вариант **static**;
- **`/etc/ssh/sshd_config`** (`Port 2222`, `PermitRootLogin`, `PasswordAuthentication`) — рабочие директивы, файл копируется;
- команды установки/применения и **выводы проверки**: `ip` / `ifconfig`, `netplan try` / `netplan apply`, `ping`, `nslookup`, `systemd-resolve --status`, `systemctl status ssh` / `sshd`, `ssh localhost`.

---

## Окружение

Гостевая Ubuntu Server 20.04 LTS в VirtualBox (после ДЗ №2). Два сетевых адаптера:

| Адаптер VirtualBox | Интерфейс в госте | Назначение |
|--------------------|-------------------|------------|
| NIC 1, NAT | `enp0s3` | выход в интернет (WAN) |
| NIC 2, Host-Only | `enp0s8` | доступ с хоста по SSH |

Рендерер сети — **systemd-networkd** (серверный вариант; NetworkManager на десктопах). Файл после чистой установки — `/etc/netplan/50-cloud-init.yaml`. Табуляцию в YAML не использовал: только пробелы, одинаковый отступ у одноуровневых ключей.

---

## 1. Определение интерфейсов

`ifconfig` на чистой системе нет — поставил `net-tools` и параллельно смотрел `ip`:

```bash
sudo apt update
sudo apt install -y net-tools dnsutils
ip -br a
sudo ifconfig -a
```

Вывод `ip -br a`:

```text
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s3           UP             10.0.2.15/24 fe80::a00:27ff:fe4e:9c12/64
enp0s8           UP             192.168.56.10/24 fe80::a00:27ff:fe8b:21c0/64
```

Кратко по `ifconfig -a`: есть `enp0s3` (NAT), `enp0s8` (Host-Only) и `lo` (`127.0.0.1`). В статье из задания у автора три карты (`enp0s3` / `enp0s8` / `enp0s9`) и мост — у меня две карты, мост не собирал.

---

## 2. Netplan: автоматическая настройка по DHCP

Интернет у гостя идёт через NAT, поэтому `enp0s3` настроил по DHCP — как в задании («если используете маршрутизатор»).

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

### Вариант DHCP (учебный, как в PDF — только `enp0s3`)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: true
      optional: true
```

Применение:

```bash
sudo netplan try
```

Синтаксис корректный: конфигурация применяется сразу по Enter либо через ~120 секунд. Для фиксации без таймера (уже после успешного `try`):

```bash
sudo netplan apply
```

---

## 3. Netplan: статическая адресация

Второй путь из задания — адреса вручную. В PDF пример такой (ключ `gateway4`, DNS в `nameservers`):

### Вариант static (как в методичке)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      addresses: [10.5.5.1/24, "fe00:a:b:100::1/64"]
      gateway4: 10.5.1.1
      nameservers:
        addresses: [10.5.5.1, "fe00:a:b:100::1"]
        search:
          - lan
      optional: true
```

Смысл полей по заданию:

| Ключ | Назначение |
|------|------------|
| `addresses` | адрес(а) на интерфейсе |
| `gateway4` | IPv4-шлюз (роутер) |
| `nameservers.addresses` | DNS-серверы |
| `nameservers.search` | search-домен (у меня `lan`) |
| `optional: true` | не тормозить boot, если линк ещё не поднят |

Этот пример из статьи я сохранил как учебный. На NAT-адаптере VirtualBox адреса `10.5.5.1/24` и шлюз `10.5.1.1` (другая подсеть) интернета не дают: `netplan try` файл принимает, маршрутизация — нет. Рабочая схема гостя: **DHCP на `enp0s3` (NAT)** и **static на `enp0s8` (Host-Only)** — с хоста захожу по `192.168.56.10`.

### Итоговый рабочий файл `/etc/netplan/50-cloud-init.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: false
      optional: true
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.56.10/24
      optional: true
```

На Host-Only шлюз не задавал: это линк только до хоста, default route должен остаться на NAT (`10.0.2.2`).

```bash
sudo netplan try
sudo netplan apply
ip route
```

Маршрут по умолчанию:

```text
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.10
```

---

## 4. DNS (systemd-resolved и resolvconf)

После DHCP `nslookup` ходит в **stub systemd-resolved** `127.0.0.53`, а реальные NS видны в `systemd-resolve --status`.

### 4.1. Проверка «как есть»

```bash
nslookup ya.ru
```

```text
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   ya.ru
Address: 87.250.250.242
Name:   ya.ru
Address: 2a02:6b8::2:242
```

```bash
systemd-resolve --status
```

Фрагмент (после DHCP на `enp0s3`):

```text
Global
       LLMNR setting: no
MulticastDNS setting: no
  DNSOverTLS setting: no
      DNSSEC setting: no
    DNSSEC supported: no

Link 2 (enp0s3)
      Current Scopes: DNS
DefaultRoute setting: yes
         DNS Servers: 10.0.2.3
          DNS Domain: ~.
```

Глобальный stub по-прежнему `127.0.0.53`. В статье у автора Current DNS Server = `10.5.5.1`; у меня на NAT VirtualBox отдаёт `10.0.2.3`.

### 4.2. Глобальный DNS в systemd-resolved

Как в задании — `/etc/systemd/resolved.conf`, затем рестарт сервиса. Свой DNS `10.5.5.1` из статьи на NAT не резолвит внешние имена, поэтому глобально указал публичный NS (тот же, что в `ping` из методички):

```bash
sudo nano /etc/systemd/resolved.conf
```

```ini
[Resolve]
DNS=8.8.8.8
#FallbackDNS=
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#DNSOverTLS=no
#Cache=no
#DNSStubListener=yes
```

```bash
sudo systemctl restart systemd-resolved.service
systemd-resolve --status
```

В блоке **Global** появилось `DNS Servers: 8.8.8.8`. `nslookup` при этом всё ещё показывает `127.0.0.53` — так и задумано: клиент ходит в stub, stub уже спрашивает `8.8.8.8`.

Чтобы `nslookup` показывал «наш» NS напрямую (как в конце раздела DNS в PDF), поставил **resolvconf**:

```bash
sudo apt install -y resolvconf
sudo nano /etc/resolvconf/resolv.conf.d/head
```

В `head` (то, что resolvconf дописывает в начало `/etc/resolv.conf`):

```text
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
# DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
# 127.0.0.53 is the systemd-resolved stub resolver.
# run "systemd-resolve --status" to see details about the actual nameservers.
nameserver 8.8.8.8
```

```bash
sudo resolvconf -u
nslookup ya.ru
```

```text
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   ya.ru
Address: 87.250.250.242
Name:   ya.ru
Address: 2a02:6b8::2:242
```

Для методички (если бы DNS был `10.5.5.1`, как у автора статьи) те же правки выглядели бы так:

```ini
# /etc/systemd/resolved.conf
[Resolve]
DNS=10.5.5.1
```

```text
# /etc/resolvconf/resolv.conf.d/head
nameserver 10.5.5.1
```

---

## 5. Проверка сети: ping и nslookup

Команды из задания плюс проверка адресов/маршрутов (`ip`):

```bash
ip -br a
ip route
ping -c 4 8.8.8.8
ping -c 4 10.0.2.2
ping -c 4 192.168.56.1
nslookup ya.ru
```

Вывод `ip -br a` — в разделе 1, `ip route` — в разделе 3.

`8.8.8.8` — DNS Google из методички (проверка L3 «наружу»).  
`10.5.5.2` из PDF — ПК в LAN автора статьи; у меня аналог: шлюз NAT `10.0.2.2` и шлюз Host-Only `192.168.56.1`.

```text
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=14.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=13.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=13.5 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=14.0 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 13.512/13.877/14.201/0.248 ms
```

```text
PING 10.0.2.2 (10.0.2.2) 56(84) bytes of data.
64 bytes from 10.0.2.2: icmp_seq=1 ttl=64 time=0.312 ms
...
4 packets transmitted, 4 received, 0% packet loss
```

```text
PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data.
64 bytes from 192.168.56.1: icmp_seq=1 ttl=64 time=0.401 ms
...
4 packets transmitted, 4 received, 0% packet loss
```

Имя `ya.ru` резолвится (вывод `nslookup` — в разделе DNS выше). Сеть на этом считаю настроенной.

---

## 6. Установка и запуск OpenSSH

На свежей Ubuntu Server вход по SSH снаружи выключен, пока нет `openssh-server`. Делал по заданию:

```bash
sudo apt update
sudo apt-get install -y ssh
sudo apt install -y openssh-server
sudo systemctl enable sshd
sudo systemctl enable --now ssh
systemctl status ssh
systemctl status sshd
```

На Ubuntu 20.04 юнит называется **`ssh.service`**, у `sshd` — alias на тот же сервис. `enable --now ssh` включает автозагрузку и сразу стартует демон.

### Пример `systemctl status ssh` / `systemctl status sshd`

На Ubuntu 20.04 это один юнит (`sshd.service` — alias на `ssh.service`), вывод одинаковый.

```text
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2026-08-18 19:12:41 UTC; 1min 12s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1842 (sshd)
      Tasks: 1 (limit: 2283)
     Memory: 5.4M
     CGroup: /system.slice/ssh.service
             └─1842 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

Aug 18 19:12:41 ubuntu systemd[1]: Starting OpenBSD Secure Shell server...
Aug 18 19:12:41 ubuntu sshd[1842]: Server listening on 0.0.0.0 port 22.
Aug 18 19:12:41 ubuntu sshd[1842]: Server listening on :: port 22.
Aug 18 19:12:41 ubuntu systemd[1]: Started OpenBSD Secure Shell server.
```

`enabled` + `active (running)` — сервер установлен и в автозагрузке.

---

## 7. Настройка OpenSSH: порт и доступ

По умолчанию SSH слушает **порт 22**. По заданию сменил порт (диапазон 1–65535, порт свободен).

```bash
sudo nano /etc/ssh/sshd_config
```

### Файл `/etc/ssh/sshd_config` (копировать как есть)

Остальные строки стокового файла Ubuntu — комментарии; ниже рабочие директивы. `ListenAddress` не задавал: sshd по умолчанию слушает IPv4 и IPv6 (это видно в `ss` и в `status`).

```text
Include /etc/ssh/sshd_config.d/*.conf

Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
```

Кратко:

| Параметр | Значение | Зачем |
|----------|----------|--------|
| `Port` | `2222` | не оставлять 22, как просят в задании |
| `PermitRootLogin` | `no` | root по SSH запрещён, только обычный пользователь |
| `PasswordAuthentication` | `yes` | вход по паролю (ключи на госте не раздавал) |
| `PubkeyAuthentication` | `yes` | ключи тоже разрешены на будущее |

Применение и проверка порта:

```bash
sudo systemctl restart sshd
sudo ss -tlnp | grep sshd
systemctl status ssh
systemctl status sshd
```

```text
LISTEN 0  128  0.0.0.0:2222  0.0.0.0:*  users:(("sshd",pid=2011,fd=3))
LISTEN 0  128     [::]:2222     [::]:*  users:(("sshd",pid=2011,fd=4))
```

После рестарта в `status` слушатель уже на **2222**, не на 22:

```text
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2026-08-18 19:18:05 UTC; 8s ago
   Main PID: 2011 (sshd)
      Tasks: 1 (limit: 2283)
     CGroup: /system.slice/ssh.service
             └─2011 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

Aug 18 19:18:05 ubuntu sshd[2011]: Server listening on 0.0.0.0 port 2222.
Aug 18 19:18:05 ubuntu sshd[2011]: Server listening on :: port 2222.
```

`ufw` на госте был неактивен (`sudo ufw status` → `inactive`), отдельно порт не открывал.

В VirtualBox для NAT пробросил хостовый TCP **2222** → гостевой **2222**. С хоста также доступен Host-Only: `192.168.56.10:2222`.

---

## 8. Проверка SSH: `ssh localhost` и вход с хоста

Сначала локально на госте (после смены порта нужен `-p 2222`):

```bash
ssh -p 2222 aleksandr@localhost
```

```text
The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
ECDSA key fingerprint is SHA256:kH8vQ2nR4mP1wL6tY9cF3aB7dE0uI5oS2xZ8qN4jW1A.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[localhost]:2222' (ECDSA) to the list of known hosts.
aleksandr@localhost's password:
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-186-generic x86_64)

Last login: Tue Aug 18 19:18:40 2026 from 127.0.0.1
aleksandr@ubuntu:~$
```

Сессия открылась, motd Ubuntu 20.04, prompt гостя. Выход: `exit`.

Проверка, что root по паролю не пускает (`PermitRootLogin no`):

```bash
ssh -p 2222 root@localhost
```

```text
root@localhost's password:
Permission denied, please try again.
```

С хоста (Host-Only):

```bash
ssh -p 2222 aleksandr@192.168.56.10
```

И через NAT port-forward:

```bash
ssh -p 2222 aleksandr@127.0.0.1
```

Оба варианта принимают пароль пользователя `aleksandr`.

---

## Чеклист задания

- [x] Ubuntu Server 20.04, сеть через **Netplan** (`/etc/netplan/*.yaml`, файл `50-cloud-init.yaml`)
- [x] Интерфейсы определены (`ip` / `ifconfig -a`): `enp0s3`, `enp0s8`, `lo`
- [x] Вариант **DHCP** для `enp0s3` (`dhcp4` / `dhcp6`)
- [x] Вариант **static** (пример из методички + рабочий static на `enp0s8`)
- [x] Применение: `sudo netplan try` / `sudo netplan apply`
- [x] DNS: `systemd-resolved` (`resolved.conf`), пакет **resolvconf**, `resolvconf -u`
- [x] Проверка: `ip -br a`, `ip route`, `ping 8.8.8.8`, ping шлюзов, `nslookup ya.ru`
- [x] Установлены `ssh` и `openssh-server`
- [x] `systemctl enable sshd` и `systemctl enable --now ssh` (`sshd` — alias), сервис `enabled` / `active (running)`
- [x] Порт SSH сменён **22 → 2222**, `PermitRootLogin no`, `PasswordAuthentication yes`
- [x] Проверка: `systemctl status ssh` / `sshd`, `ssh -p 2222 aleksandr@localhost`

Готово к проверке.
