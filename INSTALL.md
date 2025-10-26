# 🎰 Luxor Casino - Инструкция по установке

## ✅ Проверено и готово к работе

Код проверен на синтаксические ошибки и оптимизирован для работы с `pastebin run`.

---

## 📋 Шаг 1: Разместите код на Pastebin

1. Откройте [pastebin.com](https://pastebin.com)
2. Скопируйте содержимое файла **installer.lua** (см. ниже)
3. Вставьте в текстовое поле
4. Нажмите "Create New Paste"
5. Скопируйте код из URL (например, если URL `pastebin.com/ABC123`, то код `ABC123`)

---

## 🚀 Шаг 2: Запуск в OpenComputers

В консоли OpenComputers выполните:

```lua
pastebin run ABC123
```

*(Замените `ABC123` на ваш код)*

---

## 📝 Код для Pastebin (installer.lua)

```lua
-- Luxor Casino Installer for OpenComputers
-- Usage: pastebin run <CODE>

local component = require("component")
local shell = require("shell")
local internet = component.internet

if not internet then
    print("ERROR: Internet Card not found!")
    print("Please install an Internet Card.")
    return
end

print("=================================")
print("  LUXOR CASINO INSTALLER")
print("=================================")
print("")
print("Downloading from GitHub...")

local url = "https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua"
local path = "/home/casino.lua"

-- Download using wget
local result = os.execute("wget -f " .. url .. " " .. path)

if result ~= true and result ~= 0 then
    print("ERROR: Failed to download!")
    print("Check your internet connection.")
    return
end

print("Download complete!")
print("Starting Luxor Casino...")
print("")

-- Run the casino
local success, err = loadfile(path)
if not success then
    print("ERROR: Failed to load casino: " .. tostring(err))
    return
end

success, err = pcall(success)
if not success then
    print("ERROR: Runtime error: " .. tostring(err))
end
```

---

## 🔧 Требования

- **OpenComputers** (Minecraft 1.7.10)
- **GPU** (Tier 2+)
- **Screen**
- **Internet Card** ⚠️ **ОБЯЗАТЕЛЬНО**
- **HDD** с OpenOS

---

## 🎮 Игры в казино

1. **Слоты** - Ставка $10
2. **Рулетка** - Ставка $10 (Красное/Черное)
3. **Блэкджек** - Ставка $10 (упрощенная версия)

---

## 💰 Пополнение баланса

Используйте кнопку "Пополнить Баланс (PIM)" в главном меню.
В эмуляции добавляется **+$50** за клик.

---

## 📦 Альтернативная установка (без Pastebin)

```lua
wget https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua /home/casino.lua && lua /home/casino.lua
```

---

## 🔗 GitHub

https://github.com/makimyys-afk/luxor-casino

---

*Создано Manus AI*

