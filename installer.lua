-- Luxor Casino Installer for OpenComputers
-- Based on MineOS installer approach
-- Usage: pastebin run <CODE>

local component = require("component")

-- Check for internet card
if not component.isAvailable("internet") then
    print("ERROR: Internet Card required!")
    print("Please install an Internet Card.")
    return
end

print("=================================")
print("  LUXOR CASINO INSTALLER")
print("=================================")
print("")
print("Downloading from GitHub...")

local url = "https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua"

-- Use the same method as MineOS installer
local internet = component.proxy(component.list("internet")())
local connection = internet.request(url)
local data = ""

-- Read data in chunks
while true do
    local chunk = connection.read(math.huge)
    
    if chunk then
        data = data .. chunk
    else
        break
    end
end

connection.close()

-- Check if we got data
if #data == 0 then
    print("ERROR: Downloaded file is empty!")
    return
end

print("Download complete! (" .. #data .. " bytes)")
print("Starting Luxor Casino...")
print("")

-- Load and execute
local success, err = load(data, "=casino")
if not success then
    print("ERROR: Failed to load casino:")
    print(tostring(err))
    return
end

local ok, err = pcall(success)
if not ok then
    print("ERROR: Runtime error:")
    print(tostring(err))
end

