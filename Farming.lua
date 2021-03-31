local Helper = require("./Helper")

local args = {...}
local rows = 10
local lines = 3
local states = Helper.readState()

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket"
}

local acceptedSeeds = {
    "minecraft:carrot",
    "minecraft:potato",
    "minecraft:wheat_seeds"
}

local matureCrops = {
    "minecraft:carrots",
    "minecraft:potatoes",
    "minecraft:wheat"
}

local fuelSlots = {}
for x = 1, #acceptedFuels do
    local slot = Helper.GetItem(acceptedFuels[x])
    if(slot ~= nil) then
        table.insert(fuelSlots, slot)
    end
end

local seedSlots = {}
for x = 1, #acceptedSeeds do
    local slot = Helper.GetItem(acceptedSeeds[x])
    if(slot ~= nil) then
        table.insert(seedSlots, slot)
    end
end

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

local function harvest()
    turtle.digDown()
    for x = 1, #seedSlots do
        local data = turtle.getItemDetail(seedSlots[x])
        if(data ~= nil) then
            turtle.select(seedSlots[x])
            turtle.placeDown()
            return
        else
            table.remove(seedSlots, x)
        end
    end
    if(next(seedSlots) == nil) then
        for x = 1, #acceptedSeeds do
            local slot = Helper.GetItem(acceptedSeeds[x])
            if(slot ~= nil) then
                table.insert(seedSlots, slot)
                return
            end
        end
        if(next(fuelSlots) == nil) then
            error("No Seeds Any More", 0)
        end
    end
end
local function farm()
    -- deposit stuff into the chest behind it (IF CHEST IS BEHIND IT)
    for i = states[1], rows, 1 do
        for j = states[2], lines, 1 do
            local isMature = false
            for x = 1, #matureCrops do
                if(turtle.inspectDown().name == matureCrops[x]) then
                    harvest()
                end
            end
            states[2] = j + 1
        end
        states[1] = i + 1
    end
end

-- check if args are filled in, or args == -h (-h stands for --help)
if(args == nil or args == "-h") then
    error("Farming ROWS LINES \n all in CAPS are variables which you have to replace with your desired values (integer / numbers)",4)
else
    -- FIXME: this check of args doesn't work, and args are not used yet 
    if(args[1] ~= nil ) then
        rows = tonumber(args[1])
    else   
        --error("You have to specify the amount of Crossings you want\n more info try: StripMining -h",4)
    end
    if(args[2] ~= nil ) then
        lines = tonumber(args[2])
    else   
        --error("You have to specify how long the sideTunnel should be\n more info try: StripMining -h",4)
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

-- Normal Operation
term.setTextColor( colors.white )
while true do
    fuelling()
    farm()
end