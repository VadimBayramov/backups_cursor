#!/bin/bash

# Скрипт для настройки автоматических Git бэкапов через cron

# Получаем абсолютный путь к директории проекта
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$PROJECT_DIR/backup_script.sh"

echo "Настройка автоматических Git бэкапов..."
echo "Директория проекта: $PROJECT_DIR"
echo "Скрипт бэкапа: $BACKUP_SCRIPT"

# Проверяем, существует ли скрипт бэкапа
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "Ошибка: Скрипт бэкапа не найден: $BACKUP_SCRIPT"
    exit 1
fi

# Делаем скрипт исполняемым
chmod +x "$BACKUP_SCRIPT"

# Создаем временный файл с cron job
TEMP_CRON=$(mktemp)

# Добавляем комментарий
echo "# Автоматические Git бэкапы для проекта: $PROJECT_DIR" > "$TEMP_CRON"

# Добавляем cron job - бэкап каждые 30 минут
echo "*/30 * * * * cd $PROJECT_DIR && $BACKUP_SCRIPT >> $PROJECT_DIR/backup.log 2>&1" >> "$TEMP_CRON"

# Добавляем cron job - бэкап каждый час
echo "0 * * * * cd $PROJECT_DIR && $BACKUP_SCRIPT >> $PROJECT_DIR/backup.log 2>&1" >> "$TEMP_CRON"

# Добавляем cron job - бэкап каждый день в 2:00
echo "0 2 * * * cd $PROJECT_DIR && $BACKUP_SCRIPT 'Ежедневный бэкап' >> $PROJECT_DIR/backup.log 2>&1" >> "$TEMP_CRON"

echo "Созданные cron jobs:"
cat "$TEMP_CRON"

echo ""
echo "Для установки cron jobs выполните:"
echo "crontab $TEMP_CRON"
echo ""
echo "Для просмотра текущих cron jobs:"
echo "crontab -l"
echo ""
echo "Для удаления cron jobs:"
echo "crontab -r"
echo ""
echo "Логи бэкапов будут сохраняться в: $PROJECT_DIR/backup.log"

# Очищаем временный файл
rm "$TEMP_CRON" 