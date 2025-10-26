-- Luxor Casino Installer
local shell = require("shell")
local fs = require("filesystem")

print("=================================")
print("  LUXOR CASINO INSTALLER")
print("=================================")
print("")
print("Downloading from GitHub...")

local url = "https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua"
local path = "/home/casino.lua"

-- Download file
local result, reason = shell.execute("wget -f " .. url .. " " .. path)

if not result then
    print("ERROR: Failed to download!")
    print("Reason: " .. tostring(reason))
    return
end

print("Download complete!")
print("Starting Luxor Casino...")
print("")

-- Run the casino
shell.execute(path)

