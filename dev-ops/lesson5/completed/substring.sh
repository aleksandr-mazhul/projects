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
