#!/bin/bash

# Скрипт для настройки автоматических Git бэкапов через systemd timer
# Это альтернатива cron для NixOS

echo "Настройка автоматических Git бэкапов через systemd timer..."

# Получаем абсолютные пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Директория скриптов: $SCRIPT_DIR"
echo "Директория проекта: $PROJECT_DIR"

# Проверяем, что файлы существуют
if [ ! -f "$SCRIPT_DIR/backup.service" ]; then
    echo "Ошибка: Файл backup.service не найден"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/backup.timer" ]; then
    echo "Ошибка: Файл backup.timer не найден"
    exit 1
fi

# Копируем файлы в systemd директорию пользователя
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$USER_SYSTEMD_DIR"

echo "Копируем файлы в $USER_SYSTEMD_DIR..."

# Обновляем пути в service файле
sed "s|/home/diamond/app/cursor_ai/Progects|$PROJECT_DIR|g" "$SCRIPT_DIR/backup.service" > "$USER_SYSTEMD_DIR/backup.service"
sed "s|/home/diamond/app/cursor_ai/Progects|$PROJECT_DIR|g" "$SCRIPT_DIR/backup.timer" > "$USER_SYSTEMD_DIR/backup.timer"

# Делаем файлы исполняемыми
chmod +x "$SCRIPT_DIR/backup_script.sh"

echo "Перезагружаем systemd..."
systemctl --user daemon-reload

echo "Включаем и запускаем timer..."
systemctl --user enable backup.timer
systemctl --user start backup.timer

echo ""
echo "✅ Автоматические бэкапы настроены!"
echo ""
echo "📋 Команды для управления:"
echo "  Просмотр статуса: systemctl --user status backup.timer"
echo "  Остановить таймер: systemctl --user stop backup.timer"
echo "  Запустить таймер: systemctl --user start backup.timer"
echo "  Отключить таймер: systemctl --user disable backup.timer"
echo "  Просмотр логов: journalctl --user -u backup.service"
echo ""
echo "📁 Логи бэкапов: $PROJECT_DIR/rulse/backup.log"
echo "⏰ Бэкапы будут выполняться каждые 30 минут" 