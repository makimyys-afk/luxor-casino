-- Luxor Casino Installer for OpenComputers
-- Usage: pastebin run <CODE>

print("=================================")
print("  LUXOR CASINO INSTALLER")
print("=================================")
print("")
print("Downloading from GitHub...")
print("")

local url = "https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua"
local path = "casino.lua"

-- Use os.execute to run wget
local result = os.execute("wget -f " .. url .. " " .. path)

-- Check if file exists
local file = io.open(path, "r")
if not file then
    print("ERROR: Download failed!")
    print("Make sure you have an Internet Card installed.")
    return
end
file:close()

print("Download complete!")
print("Starting Luxor Casino...")
print("")

-- Load and run the casino
local success, err = loadfile(path)
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

