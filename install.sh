#!/bin/bash

# HackLab Manager Installer v2.1
# Works on Kali 2025+, Ubuntu, Debian, macOS

set -e

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│   🚀 HackLab Manager Installer v2.1     │"
echo "└──────────────────────────────────────────┘"
echo ""

HACKLAB_DIR="$HOME/.hacklab"
REPO_URL="https://github.com/argasokovk-jpg/hacklab-manager.git"
VENV_DIR="$HACKLAB_DIR/venv"

# 1. Удаляем старую версию, если есть
if [ -d "$HACKLAB_DIR" ]; then
    echo "[1/6] 🔄 Обновление HackLab Manager..."
    rm -rf "$HACKLAB_DIR"
else
    echo "[1/6] 📥 Установка HackLab Manager..."
fi

# 2. Клонируем репозиторий
git clone --depth 1 "$REPO_URL" "$HACKLAB_DIR" 2>/dev/null || {
    echo "⚠️  Не удалось клонировать. Скачиваем архив..."
    curl -L "https://github.com/argasokovk-jpg/hacklab-manager/archive/refs/heads/main.zip" -o /tmp/hacklab.zip
    unzip -q /tmp/hacklab.zip -d /tmp/
    mv "/tmp/hacklab-manager-main" "$HACKLAB_DIR"
}

# 3. Даем права на выполнение
chmod +x "$HACKLAB_DIR/main.py" "$HACKLAB_DIR/hl" 2>/dev/null || true
find "$HACKLAB_DIR/tools" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true

# 4. Создаем директории
mkdir -p "$HACKLAB_DIR/scans" "$HACKLAB_DIR/data"

# 5. Устанавливаем зависимости (УНИВЕРСАЛЬНЫЙ МЕТОД)
echo "[2/6] 🔧 Настройка окружения..."

# Проверяем систему
if [ -f "/etc/os-release" ] && grep -qi "kali" /etc/os-release; then
    # KALI 2025+ - используем venv
    echo "   → Обнаружена Kali Linux, создаем виртуальное окружение..."
    python3 -m venv "$VENV_DIR" 2>/dev/null || {
        echo "   ⚠️  Устанавливаем python3-venv..."
        sudo apt update && sudo apt install -y python3-venv
        python3 -m venv "$VENV_DIR"
    }
    
    # Активируем venv и устанавливаем зависимости
    echo "[3/6] 📦 Установка зависимостей (через venv)..."
    "$VENV_DIR/bin/pip" install --upgrade pip || true
    
    # Основные зависимости
    for pkg in requests colorama pyfiglet; do
        "$VENV_DIR/bin/pip" install "$pkg" || {
            echo "   ⚠️  Пробуем установить $pkg через apt..."
            sudo apt install -y "python3-$pkg" 2>/dev/null || true
        }
    done
    
    # Создаем скрипт-обертку с активированным venv
    cat > "$HACKLAB_DIR/run.sh" << 'EOF'
#!/bin/bash
source "$HOME/.hacklab/venv/bin/activate"
python3 "$HOME/.hacklab/main.py" "$@"
EOF
    chmod +x "$HACKLAB_DIR/run.sh"
    
elif command -v pipx &> /dev/null; then
    # Системы с pipx (новые Ubuntu)
    echo "[3/6] 📦 Установка зависимостей (через pipx)..."
    pipx ensurepath
    pipx install requests colorama pyfiglet || true
    
elif command -v pip3 &> /dev/null && [ ! -f "/etc/debian_version" ]; then
    # Не-Debian системы
    echo "[3/6] 📦 Установка зависимостей (через pip)..."
    pip3 install --user requests colorama pyfiglet || true
    
else
    # Запасной вариант
    echo "[3/6] ⚠️  Пропускаем зависимости (установите вручную если нужно)..."
    echo "   → Для работы могут понадобиться:"
    echo "   sudo apt install python3-requests python3-colorama"
fi

# 6. Добавляем в PATH
echo "[4/6] 🔗 Добавляем в PATH..."
HL_BIN="$HACKLAB_DIR/hl"

# Копируем hl в локальный bin
mkdir -p "$HOME/.local/bin"
cp "$HL_BIN" "$HOME/.local/bin/hl" 2>/dev/null || true
chmod +x "$HOME/.local/bin/hl" 2>/dev/null || true

# Настройка PATH для разных shell
if [[ "$SHELL" == *"zsh"* ]] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]] || [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# Добавляем если еще нет
if ! grep -q "\.local/bin" "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$SHELL_RC"
fi

# 7. Создаем десктопный файл (опционально)
echo "[5/6] 🎨 Создаем ярлык..."
cat > "$HOME/.local/share/applications/hacklab.desktop" << EOF 2>/dev/null || true
[Desktop Entry]
Name=HackLab Manager
Comment=Pentest Learning Platform
Exec=x-terminal-emulator -e hl
Icon=terminal
Type=Application
Categories=Education;Security;
Keywords=pentest;hacking;security;
EOF

# 8. Тестовая проверка
echo "[6/6] ✅ Проверка установки..."
if command -v hl &> /dev/null || [ -f "$HOME/.local/bin/hl" ]; then
    echo "✅ Установка завершена успешно!"
else
    # Альтернативный способ запуска
    echo "⚠️  Добавьте алиас вручную:"
    echo "   alias hl='python3 ~/.hacklab/main.py'"
    echo "   Добавьте эту строку в $SHELL_RC"
fi

echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│   Дальнейшие шаги:                          │"
echo "│   1. Перезапустите терминал                 │"
echo "│   2. Введите 'hl' для запуска               │"
│   3. 'hl learn' - обучение                       │"
│   4. 'hl scan example.com' - тестовое сканирование│
echo "└─────────────────────────────────────────────┘"
echo ""
echo "📚 Документация: https://hacklabtools.ru"
echo "🆘 Поддержка: @Hacklab_support"
echo ""
