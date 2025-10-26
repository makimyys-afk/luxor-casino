--[[
    Luxor Casino for OpenComputers (MC 1.7.10)
    Author: Manus AI
    Version: 2.1
    
    A visually appealing casino application with 3 game modes
    and PIM-like balance system.
]]

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local component = require("component")
local event = require("event")
local term = require("term")

-- Find components
local gpu = component.gpu
local screen = component.screen

if not gpu or not screen then
    error("Missing GPU or Screen component. Please install them.")
end

-- Set up display
local w, h = gpu.getResolution()
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
term.clear()

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local COLOR_BG = 0x1A1A1A
local COLOR_ACCENT = 0xCCAC00
local COLOR_TEXT = 0xFFFFFF
local COLOR_BUTTON_BG = 0x333333

-- ============================================================================
-- GLOBAL STATE
-- ============================================================================

local balance = 0.0
local currentScreen = "main"
local BALANCE_FILE = "/tmp/balance.dat"

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function loadBalance()
    local f = io.open(BALANCE_FILE, "r")
    if f then
        local data = f:read("*a")
        f:close()
        return tonumber(data) or 100.0
    else
        return 100.0
    end
end

local function saveBalance()
    local f = io.open(BALANCE_FILE, "w")
    if f then
        f:write(tostring(balance))
        f:close()
    end
end

local function drawBox(x, y, w, h, color)
    gpu.setBackground(color)
    gpu.fill(x, y, w, h, " ")
end

local function drawTextCentered(y, text, color)
    local x = math.floor((w - #text) / 2)
    gpu.setForeground(color or COLOR_TEXT)
    gpu.set(x, y, text)
end

local function drawButton(x, y, w, h, text, color)
    drawBox(x, y, w, h, color or COLOR_BUTTON_BG)
    local textX = x + math.floor((w - #text) / 2)
    local textY = y + math.floor(h / 2)
    gpu.setForeground(COLOR_TEXT)
    gpu.set(textX, textY, text)
end

-- ============================================================================
-- PIM API (Emulated)
-- ============================================================================

local function PIM_topUp(amount)
    if amount < 0 then return false, "Amount must be positive" end
    balance = balance + amount
    saveBalance()
    return true, "Success", balance
end

-- ============================================================================
-- GAME LOGIC
-- ============================================================================

local games = {}

-- Slots
games.slots = {
    name = "Слоты (Slots)",
    bet = 10,
    symbols = {"7", "BAR", "C", "L", "X"},
    run = function()
        local result = {}
        for i = 1, 3 do
            result[i] = games.slots.symbols[math.random(#games.slots.symbols)]
        end
        
        local win = 0
        if result[1] == result[2] and result[2] == result[3] then
            if result[1] == "7" then win = games.slots.bet * 100
            elseif result[1] == "BAR" then win = games.slots.bet * 50
            elseif result[1] == "C" then win = games.slots.bet * 20
            else win = games.slots.bet * 10 end
        elseif result[1] == result[2] or result[2] == result[3] or result[1] == result[3] then
            win = games.slots.bet * 2
        end
        
        balance = balance - games.slots.bet + win
        saveBalance()
        return result, win
    end
}

-- Roulette
games.roulette = {
    name = "Рулетка (Roulette)",
    bet = 10,
    run = function(choice)
        local result = math.random(0, 36)
        local color = (result == 0) and "GREEN" or (result % 2 == 0) and "BLACK" or "RED"
        
        local win = 0
        if color == choice then
            win = games.roulette.bet * 2
        end
        
        balance = balance - games.roulette.bet + win
        saveBalance()
        return result, color, win
    end
}

-- Blackjack
games.blackjack = {
    name = "Блэкджек (Blackjack)",
    bet = 10,
    getCard = function() 
        return math.min(math.random(1, 13), 10)
    end,
    getScore = function(hand)
        local score = 0
        local aces = 0
        for _, card in ipairs(hand) do
            score = score + card
            if card == 1 then aces = aces + 1 end
        end
        while score <= 11 and aces > 0 do
            score = score + 10
            aces = aces - 1
        end
        return score
    end,
    run = function(playerHand)
        local dealerHand = {games.blackjack.getCard(), games.blackjack.getCard()}
        
        while games.blackjack.getScore(dealerHand) < 17 do
            table.insert(dealerHand, games.blackjack.getCard())
        end
        
        local playerScore = games.blackjack.getScore(playerHand)
        local dealerScore = games.blackjack.getScore(dealerHand)
        
        local win = 0
        local message = ""
        
        if playerScore > 21 then
            message = "Перебор! Вы проиграли."
        elseif dealerScore > 21 or playerScore > dealerScore then
            win = games.blackjack.bet * 2
            message = "Вы выиграли!"
        elseif playerScore < dealerScore then
            message = "Вы проиграли."
        else
            win = games.blackjack.bet
            message = "Ничья (Push)."
        end
        
        balance = balance - games.blackjack.bet + win
        saveBalance()
        return dealerHand, playerScore, dealerScore, win, message
    end
}

-- ============================================================================
-- SCREEN RENDERING
-- ============================================================================

local function drawMainMenu()
    gpu.setBackground(COLOR_BG)
    gpu.fill(1, 1, w, h, " ")
    
    local titleText = " LUXOR CASINO "
    local titleX = math.floor((w - #titleText) / 2)
    gpu.setBackground(COLOR_ACCENT)
    gpu.setForeground(COLOR_BG)
    gpu.fill(titleX - 2, 2, #titleText + 4, 1, " ")
    gpu.set(titleX, 2, titleText)
    
    gpu.setBackground(COLOR_BG)
    drawTextCentered(4, "Ваш Баланс: $" .. string.format("%.2f", balance), COLOR_ACCENT)
    
    local buttonW = 24
    local buttonH = 3
    local startY = 7
    local centerX = math.floor((w - buttonW) / 2)
    
    local menuItems = {
        {text = " [SLOT] Слоты", screen = "slots", color = 0xFFFF00},
        {text = " [ROUL] Рулетка", screen = "roulette", color = 0xFF0000},
        {text = " [BLJK] Блэкджек", screen = "blackjack", color = 0x00FF00},
        {text = " [PIM] Пополнить", screen = "topup", color = 0x00FFFF},
        {text = " [EXIT] Выход", screen = "exit", color = 0xFFFFFF}
    }
    
    for i, item in ipairs(menuItems) do
        local y = startY + (i - 1) * (buttonH + 1)
        drawButton(centerX, y, buttonW, buttonH, item.text, COLOR_BUTTON_BG)
        gpu.setBackground(COLOR_BUTTON_BG)
        gpu.setForeground(item.color)
        gpu.set(centerX + 1, y + 1, item.text:sub(2, 6))
    end
end

local function drawTopUpScreen()
    gpu.setBackground(COLOR_BG)
    gpu.fill(1, 1, w, h, " ")
    
    drawTextCentered(2, "ПОПОЛНЕНИЕ БАЛАНСА (PIM)", COLOR_ACCENT)
    drawTextCentered(4, "Текущий Баланс: $" .. string.format("%.2f", balance), COLOR_TEXT)
    
    local infoW = 30
    local infoX = math.floor((w - infoW) / 2)
    drawBox(infoX, 8, infoW, 4, 0x0A0A0A)
    gpu.setForeground(0xAAAAAA)
    gpu.set(infoX + 2, 9, "PIM-модуль на Mcskill.net")
    gpu.set(infoX + 2, 10, "позволяет переводить средства.")
    gpu.set(infoX + 2, 11, "Эмуляция: +$50.00 за клик.")
    
    local buttonW = 18
    local buttonX = math.floor((w - buttonW) / 2)
    drawButton(buttonX, 14, buttonW, 3, "ПОПОЛНИТЬ +$50", COLOR_ACCENT)
    drawButton(2, h - 2, 8, 1, "Назад", COLOR_BUTTON_BG)
end

local function drawSlotsScreen()
    gpu.setBackground(COLOR_BG)
    gpu.fill(1, 1, w, h, " ")
    drawTextCentered(2, games.slots.name, COLOR_ACCENT)
    drawTextCentered(4, "Ставка: $" .. games.slots.bet, COLOR_TEXT)
    
    local slotArt = {
        " +----------+ ",
        " | 7 |BAR| C| ",
        " +----------+ "
    }
    for i, line in ipairs(slotArt) do
        drawTextCentered(7 + i, line, 0xAAAAAA)
    end
    
    drawButton(math.floor((w - 10) / 2), 12, 10, 3, "СПИН", 0xAA0000)
    drawButton(2, h - 2, 8, 1, "Назад", COLOR_BUTTON_BG)
end

local function drawRouletteScreen()
    gpu.setBackground(COLOR_BG)
    gpu.fill(1, 1, w, h, " ")
    drawTextCentered(2, games.roulette.name, COLOR_ACCENT)
    drawTextCentered(4, "Ставка: $" .. games.roulette.bet, COLOR_TEXT)
    
    local wheelArt = {
        "    /---\\    ",
        "   |R G B|   ",
        "    \\---/    "
    }
    for i, line in ipairs(wheelArt) do
        drawTextCentered(7 + i, line, 0xAAAAAA)
    end
    
    drawButton(math.floor(w/2) - 12, 12, 10, 3, "КРАСНОЕ", 0xAA0000)
    drawButton(math.floor(w/2) + 2, 12, 10, 3, "ЧЕРНОЕ", 0x000000)
    drawButton(2, h - 2, 8, 1, "Назад", COLOR_BUTTON_BG)
end

local function drawBlackjackScreen()
    gpu.setBackground(COLOR_BG)
    gpu.fill(1, 1, w, h, " ")
    drawTextCentered(2, games.blackjack.name, COLOR_ACCENT)
    drawTextCentered(4, "Ставка: $" .. games.blackjack.bet, COLOR_TEXT)
    
    local cardArt = {
        " +--+ +--+ ",
        " |A | |10| ",
        " +--+ +--+ "
    }
    for i, line in ipairs(cardArt) do
        drawTextCentered(7 + i, line, 0xFFFFFF)
    end
    
    drawButton(math.floor((w - 10) / 2), 12, 10, 3, "ИГРАТЬ", 0x00AA00)
    drawButton(2, h - 2, 8, 1, "Назад", COLOR_BUTTON_BG)
end

local function drawScreen()
    if currentScreen == "main" then
        drawMainMenu()
    elseif currentScreen == "topup" then
        drawTopUpScreen()
    elseif currentScreen == "slots" then
        drawSlotsScreen()
    elseif currentScreen == "roulette" then
        drawRouletteScreen()
    elseif currentScreen == "blackjack" then
        drawBlackjackScreen()
    else
        drawMainMenu()
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

local function handleInput(x, y)
    local buttonW = 24
    local buttonH = 3
    local centerX = math.floor((w - buttonW) / 2)
    
    if currentScreen == "main" then
        local startY = 7
        local screens = {"slots", "roulette", "blackjack", "topup", "exit"}
        
        for i, screen in ipairs(screens) do
            local btnY = startY + (i - 1) * (buttonH + 1)
            if x >= centerX and x < centerX + buttonW and y >= btnY and y < btnY + buttonH then
                if screen == "exit" then
                    return false
                else
                    currentScreen = screen
                    drawScreen()
                    return true
                end
            end
        end
        
    elseif currentScreen == "topup" then
        if x >= 2 and x < 10 and y >= h - 2 and y < h - 1 then
            currentScreen = "main"
            drawScreen()
            return true
        end
        
        local buttonW_t = 18
        local buttonX_t = math.floor((w - buttonW_t) / 2)
        if x >= buttonX_t and x < buttonX_t + buttonW_t and y >= 14 and y < 17 then
            local success, msg, newBalance = PIM_topUp(50.0)
            if success then
                balance = newBalance
                drawTextCentered(18, "Успешно! Баланс: $" .. string.format("%.2f", balance), 0x00FF00)
            else
                drawTextCentered(18, "Ошибка: " .. msg, 0xFF0000)
            end
            os.sleep(2)
            drawTopUpScreen()
            return true
        end
        
    elseif currentScreen == "slots" then
        if x >= 2 and x < 10 and y >= h - 2 and y < h - 1 then
            currentScreen = "main"
            drawScreen()
            return true
        end
        
        local buttonX_s = math.floor((w - 10) / 2)
        if x >= buttonX_s and x < buttonX_s + 10 and y >= 12 and y < 15 then
            if balance < games.slots.bet then
                drawTextCentered(17, "Недостаточно средств!", 0xFF0000)
                os.sleep(1)
                drawSlotsScreen()
                return true
            end
            
            local result, win = games.slots.run()
            
            gpu.setBackground(COLOR_BG)
            gpu.fill(1, 16, w, 3, " ")
            
            drawTextCentered(16, "Результат: " .. table.concat(result, " | "), COLOR_TEXT)
            
            if win > 0 then
                drawTextCentered(17, "ПОБЕДА! +$" .. string.format("%.2f", win), 0x00FF00)
            else
                drawTextCentered(17, "Проигрыш", 0xFF0000)
            end
            
            drawTextCentered(18, "Баланс: $" .. string.format("%.2f", balance), COLOR_ACCENT)
            os.sleep(3)
            drawSlotsScreen()
            return true
        end
        
    elseif currentScreen == "roulette" then
        if x >= 2 and x < 10 and y >= h - 2 and y < h - 1 then
            currentScreen = "main"
            drawScreen()
            return true
        end
        
        local choice = nil
        local buttonX_red = math.floor(w/2) - 12
        local buttonX_black = math.floor(w/2) + 2
        
        if x >= buttonX_red and x < buttonX_red + 10 and y >= 12 and y < 15 then
            choice = "RED"
        elseif x >= buttonX_black and x < buttonX_black + 10 and y >= 12 and y < 15 then
            choice = "BLACK"
        end
        
        if choice then
            if balance < games.roulette.bet then
                drawTextCentered(17, "Недостаточно средств!", 0xFF0000)
                os.sleep(1)
                drawRouletteScreen()
                return true
            end
            
            local result, color, win = games.roulette.run(choice)
            
            gpu.setBackground(COLOR_BG)
            gpu.fill(1, 16, w, 3, " ")
            
            local colorCode = (color == "RED") and 0xFF0000 or (color == "BLACK") and 0xFFFFFF or 0x00FF00
            drawTextCentered(16, "Выпало: " .. result .. " (" .. color .. ")", colorCode)
            
            if win > 0 then
                drawTextCentered(17, "ПОБЕДА! +$" .. string.format("%.2f", win), 0x00FF00)
            else
                drawTextCentered(17, "Проигрыш", 0xFF0000)
            end
            
            drawTextCentered(18, "Баланс: $" .. string.format("%.2f", balance), COLOR_ACCENT)
            os.sleep(3)
            drawRouletteScreen()
            return true
        end
        
    elseif currentScreen == "blackjack" then
        if x >= 2 and x < 10 and y >= h - 2 and y < h - 1 then
            currentScreen = "main"
            drawScreen()
            return true
        end
        
        local buttonX_b = math.floor((w - 10) / 2)
        if x >= buttonX_b and x < buttonX_b + 10 and y >= 12 and y < 15 then
            if balance < games.blackjack.bet then
                drawTextCentered(17, "Недостаточно средств!", 0xFF0000)
                os.sleep(1)
                drawBlackjackScreen()
                return true
            end
            
            local playerHand = {games.blackjack.getCard(), games.blackjack.getCard()}
            local dealerHand, playerScore, dealerScore, win, message = games.blackjack.run(playerHand)
            
            gpu.setBackground(COLOR_BG)
            gpu.fill(1, 15, w, 5, " ")
            
            drawTextCentered(15, "Вы: " .. table.concat(playerHand, ",") .. " (" .. playerScore .. ")", COLOR_TEXT)
            drawTextCentered(16, "Дилер: " .. table.concat(dealerHand, ",") .. " (" .. dealerScore .. ")", COLOR_TEXT)
            drawTextCentered(17, message, (win > 0 and win ~= games.blackjack.bet) and 0x00FF00 or 0xFF0000)
            drawTextCentered(18, "Баланс: $" .. string.format("%.2f", balance), COLOR_ACCENT)
            
            os.sleep(4)
            drawBlackjackScreen()
            return true
        end
    end
    
    return true
end

-- ============================================================================
-- MAIN LOOP
-- ============================================================================

balance = loadBalance()
drawScreen()

while true do
    local e, _, x, y = event.pull()
    
    if e == "touch" or e == "mouse_click" then
        if x and y then
            if not handleInput(x, y) then
                break
            end
        end
    elseif e == "key_down" then
        if y == 29 then
            break
        end
    end
end

-- Cleanup
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
term.clear()
print("Казино закрыто. Спасибо за игру!")

