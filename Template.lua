local Helper = require("./Helper")

local args = {...}
local states = Helper.readState()

local temp = { 
    1,
    1
}
if(states[1] == nil) then
    print("Generating New States.txt")
    Helper.writeState(temp)
    states = temp
end

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket",
    "bloodmagic:lava_crystal"
}

local fuelSlots = {}
for x = 1, #acceptedFuels do
    local slot = Helper.GetItem(acceptedFuels[x])
    if(slot ~= nil) then
        table.insert(fuelSlots, slot)
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
            local isnil = true
            term.setTextColor( colors.red )
            print("No Fuel Any more")
            term.setTextColor( colors.white )
            while(isnil) do
                for x = 1, #acceptedFuels do
                    local slot = Helper.GetItem(acceptedFuels[x])
                    if(slot ~= nil) then
                        table.insert(fuelSlots, slot)
                        isnil = false
                    end
                end
            end
            term.setTextColor( colors.yellow )
            print("Got Fuel, Continuing")
            term.setTextColor( colors.white )
            fuelling()
        end
    end
end

-- just walks the desired length forward
local function walk(length)
    for i = 1, length, 1 do
        turtle.forward()
    end
end

local function deposit()
    turtle.turnLeft()
    turtle.turnLeft()
    local isBlock, block = turtle.inspect()
    if(isBlock) then
        if(string.match(block.name, "chest") ~= nil) then
            local unallowedSlots = {}
            for x = 1, #fuelSlots do
                local data = turtle.getItemDetail(fuelSlots[x])
                if(data ~= nil and data.name ~= "minecraft:bucket") then
                    table.insert(unallowedSlots, fuelSlots[x])
                    return
                else
                    table.remove(fuelSlots, x)
                end
            end
            for i = 1, 16, 1 do
                turtle.select(i)
                local allowed = true
                for x = 1, #unallowedSlots do
                    if(i == unallowedSlots[x]) then
                        allowed = false
                    end
                end
                if(allowed)then
                    turtle.drop()
                end
            end
            turtle.turnLeft()
            turtle.turnLeft()
            return
        end
    end
    turtle.turnLeft()
    turtle.turnLeft()
    print("Please place a chest behind the turtle")
end

local function doStuff()
    print("doStuff finished")
end

term.setTextColor( colors.yellow )
-- check if fuel exists
if(next(fuelSlots) == nil ) then
    print("WARNING: you do not have any fuel, the turtle is likely to run out of juice \n Current Fuel: ", turtle.getFuelLevel())
end

-- Normal Operation
term.setTextColor( colors.white )

print("Startup finished")
while true do
    fuelling()
    doStuff()
    deposit()
    sleep(400)
end