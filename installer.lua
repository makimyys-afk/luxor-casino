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

