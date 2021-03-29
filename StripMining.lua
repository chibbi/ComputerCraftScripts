local Helper = require("./Helper.lua")

local acceptedFuels = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket"
}

local trash = {
    "minecraft:coal_block",
    "minecraft:coal"
}

local FuelSlot = {}
for x = 1, #acceptedFuels do
    table.insert(FuelSlot, Helper.GetItem(x))
end