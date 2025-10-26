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

