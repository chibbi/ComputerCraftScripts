local dire = "ChibbiScripts/"
local url = "https://raw.githubusercontent.com/chibbi/ComputerCraftScripts/main/"

if(fs.exists(dire)) then
    fs.delete(dire)
end
fs.makeDir(dire)

local primaryRequest = http.get(url .. "scriptList.txt")
local allFiles = primaryRequest.readAll()

for i = 1, #allFiles, 1 do
    local fileName = allFiles[i]
    local request = http.get(url .. fileName)
    local file = fs.open(dire .. fileName, "w")
    file.write(request.readAll())
end