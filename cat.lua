local tArgs = {...}
local sPath = shell.resolve(tArgs[1])
if #tArgs == 0 then
	print("Usage: cat <path>")
	return
end
local file = fs.open(sPath, "r")
textutils.pagedPrint( file.readAll() )
