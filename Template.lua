local Helper = require("./Helper.lua")

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket"
}

local fuelSlots = {}

for x = 1, #acceptedFuels do
    table.insert(fuelSlots, Helper.GetItem(x))
end

local function fuelling()
    if(turtle.getFuelLevel ~= "unlimited" and turtle.getFuelLevel() < 1) then
        for x = 1, #fuelSlots do
            if(data ~= nil) then
                turtle.select(x)
                turtle.refuel()
            else
                table.remove(x)
            end
        end
    end
end

local function walk(length)
    for i = 1, length, 1 do
        turtle.forward()
    end
end