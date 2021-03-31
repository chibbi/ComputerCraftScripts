local Helper = require("./Helper")

local args = {...}
local states = Helper.readState()

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
    local slot = Helper.GetItem(acceptedFuels[x])
    if(slot ~= nil) then
        table.insert(fuelSlots, slot)
    end
end

local torchSlot = Helper.GetItem("minecraft:torch")

local chestSlot = Helper.GetItem("minecraft:chest")

-- fuels the turtle and updates the fueltable
local function fuelling()
    if(turtle.getFuelLevel ~= "unlimited" and turtle.getFuelLevel() < 50) then
        for x = 1, #fuelSlots do
            local data = turtle.getItemDetail(fuelSlots[x])
            if(data ~= nil) then
                turtle.select(fuelSlots[x])
                turtle.refuel()
                return
            else
                table.remove(fuelSlots, x)
            end
        end
        if(next(fuelSlots) == nil) then
            for x = 1, #acceptedFuels do
                local slot = Helper.GetItem(acceptedFuels[x])
                if(slot ~= nil) then
                    table.insert(fuelSlots, slot)
                    return
                end
            end
            if(next(fuelSlots) == nil) then
                error("No Fuel Any More", 0)
            end
        end
    end
end

-- just walks the desired length forward
local function walk(length)
    for i = 1, length, 1 do
        turtle.forward()
    end
end

local function farm()
    for i = 1, 10, 1 do
        
    end
end

Helper.writeState(acceptedFuels)

-- chechk if args are filled in, or args == -h (-h stands for --help)
if(args == nil or args == "-h") then
    error("stripmine AMOUNTOFCROSSINGS SIDETUNNELLENGTH DISTANCEBETWEENCROSSINGS \n all in CAPS are variables which you have to replace with your desired values (integer / numbers)",4)
else
    -- FIXME: this check of args doesn't work, and args are not used yet 
    if(args[1] ~= nil ) then
        amountCrossings = tonumber(args[1])
    else   
        --error("You have to specify the amount of Crossings you want\n more info try: StripMining -h",4)
    end
    if(args[2] ~= nil ) then
        sideTunnelLength = tonumber(args[2])
    else   
        --error("You have to specify how long the sideTunnel should be\n more info try: StripMining -h",4)
    end
    if(args[3] ~= nil ) then
        distanceBetweenCrossings = tonumber(args[3])
    else   
        --error("You have to specify how long the Distance between two Crossings should be\n more info try: StripMining -h",4)
    end
end
term.setTextColor( colors.yellow )
-- check if enough torches
if(torchSlot == nil or turtle.getItemCount(torchSlot) <= amountCrossings /2 ) then
    print("WARNING: you do not have enough torches in the inventory to light up the mine")
end
-- check if fuel exists
if(next(fuelSlots) == nil ) then
    print("WARNING: you do not have any fuel, the turtle is likely to run out of juice \n Current Fuel: ", turtle.getFuelLevel())
end
-- check if chests exist
if(chestSlot == nil or turtle.getItemCount(chestSlot) < 1  ) then
    print("WARNING: you do not have any chests in the inventory, some ores will likely be lost")
end

-- Normal Operation
term.setTextColor( colors.white )
while true do
    fuelling()
    for x = 1, #trash do
        Helper.DropItem(trash[x])
    end
    farm()
end