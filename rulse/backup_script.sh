#!/bin/bash

# Скрипт автоматических Git бэкапов с умными наименованиями
# Использование: ./backup_script.sh [сообщение_коммита]

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Переходим в родительскую директорию проекта (где должен быть Git репозиторий)
PROJECT_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
cd "$PROJECT_DIR"

info "Проект: $PROJECT_NAME"
info "Директория: $PROJECT_DIR"

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
    
    # Получаем информацию о последних изменениях
    CHANGED_FILES=$(git diff --cached --name-only | head -3 | tr '\n' ', ' | sed 's/,$//')
    CHANGED_COUNT=$(git diff --cached --name-only | wc -l)
    
    # Определяем тип изменений
    if [ "$CHANGED_COUNT" -eq 1 ]; then
        CHANGE_TYPE="файл"
    elif [ "$CHANGED_COUNT" -lt 5 ]; then
        CHANGE_TYPE="файлы"
    else
        CHANGE_TYPE="файлов"
    fi
    
    # Создаем умное сообщение коммита
    if [ -n "$1" ]; then
        COMMIT_MESSAGE="$1"
    else
        TIMESTAMP=$(date +'%Y-%m-%d %H:%M')
        COMMIT_MESSAGE="🔄 $PROJECT_NAME | $TIMESTAMP | Изменено $CHANGED_COUNT $CHANGE_TYPE: $CHANGED_FILES"
    fi
    
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

# Показываем последние коммиты с красивым форматированием
log "Последние бэкапы:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git log --oneline -5 --graph --pretty=format:"%C(yellow)%h%Creset - %C(blue)%ad%Creset - %s" --date=format:"%H:%M %d/%m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 