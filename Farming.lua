local Helper = require("./Helper")

local args = {...}
local rows = 3
local lines = 10
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

local acceptedSeeds = {
    "minecraft:carrot",
    "minecraft:potato",
    "minecraft:wheat_seeds"
}

local fuelSlots = {}
for x = 1, #acceptedFuels do
    local slot = Helper.GetItem(acceptedFuels[x])
    if(slot ~= nil) then
        table.insert(fuelSlots, slot)
    end
end

local seedSlots = {1}
-- it will take the stuff out of 16 slot
-- for x = 1, #acceptedSeeds do
--    local slot = Helper.GetItem(acceptedSeeds[x])
--    if(slot ~= nil) then
--        table.insert(seedSlots, slot)
--    end
-- end

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
                else
                    table.remove(fuelSlots, x)
                end
            end
            table.insert(unallowedSlots, seedSlots[1])
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
        local isnil = true
            term.setTextColor( colors.red )
            print("No seeds any more")
            term.setTextColor( colors.white )
            while(isnil) do
                for x = 1, #acceptedSeeds do
                    local slot = Helper.GetItem(acceptedSeeds[x])
                    if(slot ~= nil) then
                        table.insert(seedSlots, slot)
                        isnil = false
                    end
                end
            end
            term.setTextColor( colors.yellow )
            print("Got seeds, Continuing")
            term.setTextColor( colors.white )
            harvest()
    end
end

local function farm()
    for i = tonumber(states[1]), rows, 1 do
        for j = tonumber(states[2]), lines, 1 do
            local isBlock, block = turtle.inspectDown()
            if(isBlock) then
                if(block.state.age == 7) then
                    harvest()
                end
            else
                harvest()
            end
            turtle.forward()
            states[2] = j + 1
            Helper.writeState(states)
        end
        states[2] = 1
        -- change 1 to a 0 if the turtle is at the right corner of the field
        -- and rewrite the back to base stuff under "states[1] = 1"
        if(i % 2 == 1) then
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
            turtle.forward()
        else
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.forward()
        end
        states[1] = i + 1
        Helper.writeState(states)
    end
    states[1] = 1
    if(rows % 2 == 0) then
        turtle.turnLeft()
        walk(rows)
        turtle.turnRight()
    else
        walk(lines - 1)
        turtle.turnRight()
        walk(rows)
        turtle.turnRight()
    end
    print("field harvested")
end

-- check if args are filled in, or args == -h (-h stands for --help)
if(args == nil or args == "-h") then
    error("Farming ROWS LINES \n all in CAPS are variables which you have to replace with your desired values (integer / numbers)",4)
else
    if(args[1] ~= nil ) then
        rows = tonumber(args[1])
    end
    if(args[2] ~= nil ) then
        lines = tonumber(args[2])
    end
end
term.setTextColor( colors.yellow )
-- check if enough seeds
if(seedSlots[1] == nil or turtle.getItemCount(seedSlots[1]) < 1 ) then
    print("WARNING: you do not have any seeds in the ",seedSlots[1], " slot")
end
-- check if fuel exists
if(next(fuelSlots) == nil ) then
    print("WARNING: you do not have any fuel, the turtle is likely to run out of juice \nCurrent Fuel: ", turtle.getFuelLevel())
end

-- Normal Operation
term.setTextColor( colors.white )

print("Startup finished")
while true do
    fuelling()
    farm()
    deposit()
    sleep(400)
end