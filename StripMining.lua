local Helper = require("./Helper")

local args = {...}
local amountCrossings = 5 -- DEFAULT
local sideTunnelLength = 5 -- DEFAULT
local distanceBetweenCrossings = 5 -- DEFAULT

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
    if(Helper.isInvFull()) then
        turtle.select(chestSlot)
        turtle.placeDown()
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
        for i = 1, 16, 1 do
            local allowed = true
            for x = 1, #unallowedSlots do
                if(i == x) then
                    allowed = false
                end
            end
            if(allowed)then
                turtle.dropDown()
            end
        end   
    end
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
    digForwardTunnel(distanceBetween)
end

-- if args == -h then print help
if(args == "-h" or args == nil) then
    error("stripmine AMOUNTOFCROSSINGS SIDETUNNELLENGTH DISTANCEBETWEENCROSSINGS \n all in CAPS are variables which you have to replace with your desired values (integer / numbers)",4)
else
    if(args[0] ~= nil and tonumber(args[0]) >= 1 ) then
        amountCrossings = tonumber(args[0])
    else   
        error("You have to specify the amount of Crossings you want\n more info try: StripMining -h",4)
    end
    if(args[1] ~= nil and tonumber(args[1]) >= 1 ) then
        sideTunnelLength = tonumber(args[1])
    else   
        error("You have to specify how long the sideTunnel should be\n more info try: StripMining -h",4)
    end
    if(args[2] ~= nil and tonumber(args[2]) >= 1 ) then
        distanceBetweenCrossings = tonumber(args[2])
    else   
        error("You have to specify how long the Distance between two Crossings should be\n more info try: StripMining -h",4)
    end
end
-- check if enough torches
if(torchSlot ~= nil and turtle.getItemCount(torchSlot) <= args[0] /2 ) then
    print("WARNING: you do not have enough torches in the inventory to light up the mine")
end
-- check if fuel exists
for x = 1, #fuelSlots do
    if(x ~= nil and turtle.getItemCount(x) <= 1 ) then
        print("WARNING: you do not have any fuel, the turtle is likely to run out of juice")
    end
end
-- check if chests exist
if(chestSlot ~= nil and turtle.getItemCount(chestSlot) < 1  ) then
    print("WARNING: you do not have any chests in the inventory, some ores will likely be lost")
end
for i = 1, args[0], 1 do
    fuelling()
    clearInventory()
    crossingToCrossing(args[1], args[2])
    if(i % 2 == 0) then
        turtle.select(torchSlot)
        turtle.placeDown()
    end
    print("Finished Crossing ",i, " with ", turtle.getFuelLevel, " Fuel")
end

print("EYYYY i amma finished tha maammaaa ")

