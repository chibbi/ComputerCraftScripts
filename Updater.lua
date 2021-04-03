local dire = "ChibbiScripts/"
local url = "https://raw.githubusercontent.com/chibbi/ComputerCraftScripts/main/"

if(fs.exists(dire)) then
    fs.delete(dire)
end
fs.makeDir(dire)

local primaryRequest = http.get(url .. "scriptList.txt")
local allFiles = {}
local temp = primaryRequest.readAll()
temp:gsub(".",function(c) table.insert(allFiles,c) end)
for i = 1, #allFiles, 1 do
    local fileName = allFiles[i]
    local request = http.get(url .. fileName)
    local err, file = fs.open(dire .. fileName, "w") -- => FIXME: file doesn't exist yet
    file.write(request.readAll())
end