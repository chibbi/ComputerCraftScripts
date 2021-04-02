local Helper = require("./Helper")

-- TODO/Future Plan: add states here too (like Farming) but not sure if i will do it


local args = {...}

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

local saplingSlots = {}
for i = 1, 16, 1 do
    local data = turtle.getItemDetail(i)
    if(data ~= nil) then
        if(string.match(data.name, "sapling") ~= nil) then
            table.insert(saplingSlots, i)
        end
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
            print("Depositing assets")
            local unallowedSlots = {}
            for x = 1, #fuelSlots do
                local data = turtle.getItemDetail(fuelSlots[x])
                if(data ~= nil and data.name ~= "minecraft:bucket") then
                    table.insert(unallowedSlots, fuelSlots[x])
                else
                    table.remove(fuelSlots, x)
                end
            end
            for x = 1, #saplingSlots do
                local data = turtle.getItemDetail(saplingSlots[x])
                if(data ~= nil and data.name ~= "minecraft:bucket") then
                    table.insert(unallowedSlots, saplingSlots[x])
                else
                    table.remove(saplingSlots, x)
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

local function allAroundDig()
    for i = 1, 4, 1 do
        turtle.dig()
        turtle.turnLeft()
    end
end

local function placeSapling()
    for x = 1, #saplingSlots do
        local data = turtle.getItemDetail(saplingSlots[x])
        if(data ~= nil) then
            turtle.select(saplingSlots[x])
            turtle.place()
            return
        else
            table.remove(saplingSlots, x)
        end
    end
    if(next(saplingSlots) == nil) then
        local isnil = true
        term.setTextColor( colors.red )
        print("No saplings any more")
        term.setTextColor( colors.white )
        while(isnil) do
            for i = 1, 16, 1 do
                local data = turtle.getItemDetail(i)
                    if(data ~= nil) then
                    if(string.match(data.name, "sapling") ~= nil) then --FIXME
                        -- Too long without yielding
                        table.insert(saplingSlots, i)
                    end
                end
            end
        end
        term.setTextColor( colors.yellow )
        print("Got saplings, Continuing")
        term.setTextColor( colors.white )
        placeSapling()
    end
end

local function fell()
    turtle.dig()
    turtle.forward()
    local goneUp = 1
    while(turtle.inspectUp()) do
        allAroundDig()
        turtle.digUp()
        turtle.up(0)
        goneUp = goneUp + 1;
    end
    for i = 1, goneUp, 1 do
        turtle.down()
    end
    turtle.back()
    print("cut down the tree")
end

term.setTextColor( colors.yellow )
-- check if fuel exists
if(next(fuelSlots) == nil ) then
    print("WARNING: you do not have any fuel, the turtle is likely to run out of juice \nCurrent Fuel: ", turtle.getFuelLevel())
end
if(next(saplingSlots) == nil ) then
    print("WARNING: you do not have any saplings, the turtle is likely not able to place a new tree")
end

-- Normal Operation
term.setTextColor( colors.white )

print("Startup finished")
while true do
    fuelling()
    local isBlock, block = turtle.inspect()
    if(isBlock) then
        if(string.match(block.name, "log") ~= nil) then
            print("DEBUG: Felling")
            fell()
        end
    else
        print("DEBUG: placing sapling")
        placeSapling()
    end
    deposit()
end