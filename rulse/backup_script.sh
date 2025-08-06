#!/bin/bash

# Скрипт автоматических Git бэкапов
# Использование: ./backup_script.sh [сообщение_коммита]

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Переходим в родительскую директорию проекта (где должен быть Git репозиторий)
PROJECT_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
cd "$PROJECT_DIR"

# Проверяем, находимся ли мы в Git репозитории
if [ ! -d ".git" ]; then
    error "Не найден Git репозиторий. Инициализируем новый..."
    git init
    log "Git репозиторий инициализирован"
fi

# Проверяем статус
log "Проверяем статус репозитория..."
git status --porcelain

# Если есть изменения
if [ -n "$(git status --porcelain)" ]; then
    log "Найдены изменения, добавляем в staging..."
    
    # Добавляем все изменения
    git add .
    
    # Создаем коммит
    COMMIT_MESSAGE=${1:-"Автоматический бэкап $(date +'%Y-%m-%d %H:%M:%S')"}
    git commit -m "$COMMIT_MESSAGE"
    
    log "Коммит создан: $COMMIT_MESSAGE"
    
    # Проверяем, настроен ли удаленный репозиторий
    if git remote get-url origin >/dev/null 2>&1; then
        log "Пушим в удаленный репозиторий..."
        git push origin main 2>/dev/null || git push origin master 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log "Успешно запушено в удаленный репозиторий"
        else
            warning "Не удалось запушеть в удаленный репозиторий"
        fi
    else
        warning "Удаленный репозиторий не настроен. Настройте origin:"
        warning "git remote add origin <URL_ВАШЕГО_РЕПОЗИТОРИЯ>"
    fi
else
    log "Изменений не найдено"
fi

# Показываем последние коммиты
log "Последние коммиты:"
git log --oneline -5 