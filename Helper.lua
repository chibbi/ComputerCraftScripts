local function GetItem(desiredItemID) 
    for i = 1, 16, 1 do
        local data = turtle.getItemDetail(i)
        if(data ~= nil) then
            if(data.name == desiredItemID) then
                return i
            end
        end
    end
end

local function DropItem(desiredItemID) 
    for i = 1, 16, 1 do
        local data = turtle.getItemDetail(i)
        if(data ~= nil) then
            if(data.name == desiredItemID) then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
end

local function isInvFull()
    for i = 1, 16, 1 do
        local data = turtle.getItemDetail(i)
        if(data == nil) then
                return false
        end
    end
    return true
end

local function readState() 
    local file = fs.open("State.txt","a")
    file.flush()
    return fs.open("State.txt","r")
end

local function writeState(state) 
    local file = fs.open("State.txt","w")
    file.write(state)
    file.flush()
end


return { GetItem = GetItem, DropItem = DropItem, isInvFull = isInvFull, readState = readState, writeState = writeState}