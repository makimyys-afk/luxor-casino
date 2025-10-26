# 🎰 Luxor Casino - Инструкция по установке

## ✅ ИСПРАВЛЕНО! Готово к работе

**Проблема с правами доступа решена!** Теперь файлы сохраняются в `/tmp/`.

---

## 📋 Шаг 1: Разместите код на Pastebin

1. Откройте [pastebin.com](https://pastebin.com)
2. Скопируйте код ниже
3. Вставьте в текстовое поле
4. Нажмите "Create New Paste"
5. Скопируйте код из URL (например, `ABC123`)

---

## 🚀 Шаг 2: Запуск в OpenComputers

```lua
pastebin run ABC123
```

---

## 📝 ИСПРАВЛЕННЫЙ КОД для Pastebin

```lua
-- Luxor Casino Installer for OpenComputers
-- Usage: pastebin run <CODE>

local component = require("component")
local fs = require("filesystem")

-- Check for internet card
if not component.isAvailable("internet") then
    print("ERROR: Internet Card not found!")
    print("Please install an Internet Card.")
    return
end

local internet = component.internet

print("=================================")
print("  LUXOR CASINO INSTALLER")
print("=================================")
print("")
print("Downloading from GitHub...")

local url = "https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua"
local path = "/tmp/casino.lua"

-- Download file using internet component
local request = internet.request(url)
if not request then
    print("ERROR: Failed to create request!")
    return
end

-- Wait for response
local result = ""
for chunk in request do
    result = result .. chunk
end

if #result == 0 then
    print("ERROR: Downloaded file is empty!")
    return
end

-- Save to file
local file = io.open(path, "w")
if not file then
    print("ERROR: Cannot create file at " .. path)
    return
end

file:write(result)
file:close()

print("Download complete! (" .. #result .. " bytes)")
print("Starting Luxor Casino...")
print("")

-- Run the casino
local success, err = loadfile(path)
if not success then
    print("ERROR: Failed to load casino:")
    print(tostring(err))
    return
end

success, err = pcall(success)
if not success then
    print("ERROR: Runtime error:")
    print(tostring(err))
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

## 🎮 Игры

1. **Слоты** - $10
2. **Рулетка** - $10
3. **Блэкджек** - $10

---

## 🔗 GitHub

https://github.com/makimyys-afk/luxor-casino

---

*Manus AI*

