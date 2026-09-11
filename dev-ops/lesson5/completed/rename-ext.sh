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
