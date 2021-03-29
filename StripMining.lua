local Helper = require("./Helper.lua")

local amountCrossings = 5 -- PARAMETER
local sideTunnelLength = 5 -- PARAMETER
local distanceBetweenCrossings = 5 -- PARAMETER

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket"
}

local trash = {
    "minecraft:cobblestone"
}

local fuelSlots = {}
for x = 1, #acceptedFuels do
    table.insert(fuelSlots, Helper.GetItem(x))
end

local torchSlot = Helper.GetItem("minecraft:torch")

local chestSlot = Helper.GetItem("minecraft:chest")

local function fuelling()
    if(turtle.getFuelLevel ~= "unlimited" and turtle.getFuelLevel() < 1) then
        for x = 1, #fuelSlots do
            local data = turtle.getItemDetail(x)
            if(data ~= nil) then
                turtle.select(x)
                turtle.refuel()
                return
            else
                table.remove(x)
            end
        end
        if(next(fuelSlots) == nil) then
            error("No Fuel Any More", 0)
        end
    end
end

local function clearInventory()
    local unallowedSlots = {}
    for x = 1, #fuelSlots do
        local data = turtle.getItemDetail(x)
        if(data ~= nil) then
            unallowedSlots.insert(x)
            return
        else
            table.remove(x)
        end
    end
    if(turtle.getItemDetail(torchSlot) ~= nil) then
        unallowedSlots.insert(torchSlot)
    end
    if(turtle.getItemDetail(chestSlot) ~= nil) then
        unallowedSlots.insert(chestSlot)
    end
    Helper.clearInv()
end

local function walk(length)
    for i = 1, length, 1 do
        turtle.forward()
    end
end

local function digForwardTunnel(tunnelLength)
    for i = 1, tunnelLength, 1 do
        turtle.digUp()
        turtle.digDown()
        turtle.dig()
        turtle.forward()
    end
end

local function crossingToCrossing(tunnelLength, distanceBetween)
    turtle.turnLeft()
    for i = 1, 2, 1 do
        digForwardTunnel(tunnelLength)
        turtle.turnRight()
        turtle.turnRight()
        walk(tunnelLength)
    end
    turtle.turnRight()
    digForwardTunnel(distancebetween)
end

-- if args == -h then print help
-- check if enough torches
-- warning if no fuel or chest
for i = 1, amountCrossings, 1 do
    fuelling()
    clearInventory()
    crossingToCrossing(sideTunnelLength, distanceBetweenCrossings)
    if(i % 2 == 0) then
        turtle.select(torchSlot)
        turtle.placeDown()
    end
    print("Finished Crossing ",i, " with ", turtle.getFuelLevel, " Fuel")
end

print("EYYYY i amma finished tha maammaaa ")

