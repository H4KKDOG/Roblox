local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local PetEggData = ReplicatedStorage.Assets.Models.EggModels
local MutationHandler = require(ReplicatedStorage.Modules.MutationHandler)
local SeedData = require(ReplicatedStorage.Data.SeedData)
local GearData = require(ReplicatedStorage.Data.GearData)
local NightEventShopData = require(ReplicatedStorage.Data.NightEventShopData)
local EventShopData = require(ReplicatedStorage.Data.EventShopData)

local AllMutation = {}
local AllFruitSeed = {}
local AllEgg = {}
local SeedStock = {}
local GearStock = {}
local NightStock = {}
local FruitStock = {}
local EventStock = {}

for Name, _ in pairs(MutationHandler) do
    table.insert(AllMutation, Name)
end

for Name, _ in pairs(SeedData) do
    table.insert(AllFruitSeed, Name)
end

for _, Data in ipairs(PetEggData:GetChildren()) do
    if Data:IsA("Model") then
        table.insert(AllEgg, Data.Name)
    end
end

for Name, Data in pairs(SeedData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        table.insert(SeedStock, Name)
    end
end

for Name, Data in pairs(GearData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        table.insert(GearStock, Name)
    end
end

for Name, Data in pairs(NightEventShopData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        table.insert(NightStock, Name)
    end
end

for Name, Data in pairs(SeedData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        table.insert(FruitStock, Name)
    end
end

for Name, Data in pairs(EventShopData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        table.insert(EventStock, Name)
    end
end

table.sort(AllMutation)
table.sort(AllFruitSeed)
table.sort(AllEgg)
table.sort(SeedStock)
table.sort(GearStock)
table.sort(NightStock)
table.sort(FruitStock)
table.sort(EventStock)

local function FormatTable(Table, Indent)
    Indent = Indent or 1
    local Result = "{\n"
    local Spacer = string.rep("    ", Indent)
    
    for I, Value in ipairs(Table) do
        Result = Result .. Spacer .. '"' .. Value .. '"'
        if I < #Table then Result = Result .. "," end
        Result = Result .. "\n"
    end
    
    return Result .. string.rep("    ", Indent-1) .. "}"
end

local ClipboardText = "return {\n" ..
    "    AllMutation = " .. FormatTable(AllMutation, 2) .. ",\n" ..
    "    AllFruitSeed = " .. FormatTable(AllFruitSeed, 2) .. ",\n" ..
    "    AllEgg = " .. FormatTable(AllEgg, 2) .. ",\n" ..
    "    SeedStock = " .. FormatTable(SeedStock, 2) .. ",\n" ..
    "    GearStock = " .. FormatTable(GearStock, 2) .. ",\n" ..
    "    NightStock = " .. FormatTable(NightStock, 2) .. ",\n" ..
    "    FruitStock = " .. FormatTable(FruitStock, 2) .. ",\n" ..
    "    EventStock = " .. FormatTable(EventStock, 2) .. "\n" ..
"}"

setclipboard(ClipboardText)
