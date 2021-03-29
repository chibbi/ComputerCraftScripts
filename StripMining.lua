local Helper = require("./Helper")

local args = {...}
local amountCrossings = 5 -- DEFAULT
local sideTunnelLength = 5 -- DEFAULT
local distanceBetweenCrossings = 3 -- DEFAULT

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket"
}

-- TODO: this will be used to dump this out, without polluting the chests (not in yet)
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
        print("fuelling: DEBUG")
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
                end
            end
            if(next(fuelSlots) == nil) then
                error("No Fuel Any More", 0)
            end
        end
    end
end

-- cleans the Inventory from any ores and stone/ obsidian
-- without putting torches fuel or chests out of its inventory
local function clearInventory()
    print("CLeaining: DEBUG")
    for x = 1, #trash do
        Helper.DropItem(trash[x])
    end
    if(Helper.isInvFull()) then
        print("Inventory is full")
        if(chestSlot ~= nil) then
            if(turtle.getItemDetail(chestSlot).name == "minecraft:chest") then
                print("Depositing into Chest")
                turtle.back()
                turtle.select(chestSlot)
                turtle.placeDown()
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
                if(turtle.getItemDetail(torchSlot) ~= nil) then
                    table.insert(unallowedSlots, torchSlot)
                end
                if(turtle.getItemDetail(chestSlot) ~= nil) then
                    table.insert(unallowedSlots, chestSlot)
                end
                for i = 1, 16, 1 do
                    local allowed = true
                    for x = 1, #unallowedSlots do
                        if(i == unallowedSlots[x]) then
                            allowed = false
                        end
                    end
                    if(allowed)then
                        turtle.dropDown()
                    end
                end
                turtle.forward()
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

-- is just digging a three high one wide tunnel (digs down, up and forward)
local function digForwardTunnel(tunnelLength)
    for i = 1, tunnelLength, 1 do
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        turtle.digDown()
    end
end

-- Does the whole stripmine from one crossing to another
-- aka. form one sidetunnel to another
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

-- chechk if args are filled in, or args == -h (-h stands for --help)
if(args == nil or args == "-h") then
    error("stripmine AMOUNTOFCROSSINGS SIDETUNNELLENGTH DISTANCEBETWEENCROSSINGS \n all in CAPS are variables which you have to replace with your desired values (integer / numbers)",4)
else
    -- FIXME: this check of args doesn't work, and args are not used yet 
    if(args[0] ~= nil ) then
        amountCrossings = tonumber(args[0])
    else   
        --error("You have to specify the amount of Crossings you want\n more info try: StripMining -h",4)
    end
    if(args[1] ~= nil ) then
        sideTunnelLength = tonumber(args[1])
    else   
        --error("You have to specify how long the sideTunnel should be\n more info try: StripMining -h",4)
    end
    if(args[2] ~= nil ) then
        distanceBetweenCrossings = tonumber(args[2])
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
    print("WARNING: you do not have any fuel, the turtle is likely to run out of juice Current Juice: ", turtle.getFuelLevel())
end
-- check if chests exist
if(chestSlot == nil or turtle.getItemCount(chestSlot) < 1  ) then
    print("WARNING: you do not have any chests in the inventory, some ores will likely be lost")
end

-- Normal Operation
term.setTextColor( colors.white )
for i = 1, amountCrossings, 1 do
    fuelling()
    clearInventory()
    crossingToCrossing(sideTunnelLength, distanceBetweenCrossings)
    if(i % 2 == 0 and torchSlot ~= nil) then
        print(turtle.getItemDetail(torchSlot).name, " == minecraft:torch")
        if(turtle.getItemDetail(torchSlot).name == "minecraft:torch") then
            print("Placing Torch")
            turtle.select(torchSlot)
            turtle.placeUp()
        end
    end
    print("Finished Crossing ",i, " with ", turtle.getFuelLevel(), " Fuel")
end

print("EYYYY i amma finished tha maammaaa ")

