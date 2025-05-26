local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local PetEggData = ReplicatedStorage.Assets.Models.EggModels
local MutationHandler = require(ReplicatedStorage.Modules.MutationHandler)
local ItemData = require(ReplicatedStorage.Item_Module)
local SeedData = require(ReplicatedStorage.Data.SeedData)
local GearData = require(ReplicatedStorage.Data.GearData)
local NightEventShopData = require(ReplicatedStorage.Data.NightEventShopData)
local EventShopData = require(ReplicatedStorage.Data.EventShopData)

local MutationValue = {}
local FruitSeedValue = {}
local AllEgg = {}

local SeedStock = {}
local GearStock = {}
local NightStock = {}
local EventStock = {}

for Name, Data in pairs(MutationHandler:GetMutations()) do
    MutationValue[Name] = {
        ValueMulti = Data.ValueMulti
    }
end

for _, Data in ipairs(ItemData.Return_All_Data()) do
    FruitSeedValue[Data[1]] = {
        Weight = Data[2],
        Value = Data[3],
        Rarity = Data[4]
    }
end

for _, Model in ipairs(PetEggData:GetChildren()) do
    if Model:IsA("Model") then
        table.insert(AllEgg, Model.Name)
    end
end

for Name, Data in pairs(SeedData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        SeedStock[Name] = true
    end
end

for Name, Data in pairs(GearData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        GearStock[Name] = true
    end
end

for Name, Data in pairs(NightEventShopData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        NightStock[Name] = true
    end
end

for Name, Data in pairs(EventShopData) do
    if (Data.StockChance and Data.StockChance > 0) or Data.DisplayInShop then
        EventStock[Name] = true
    end
end

local function DictKeysToSortedList(Dict)
    local List = {}

    for Key in pairs(Dict) do
        table.insert(List, Key)
    end

    table.sort(List)

    return List
end

SeedStock = DictKeysToSortedList(SeedStock)
GearStock = DictKeysToSortedList(GearStock)
NightStock = DictKeysToSortedList(NightStock)
EventStock = DictKeysToSortedList(EventStock)

local function FormatTable(Table, Indent)
    Indent = Indent or 1
    local Result = "{\n"
    local Spacer = string.rep("    ", Indent)

    for I, Value in ipairs(Table) do
        Result = Result .. Spacer .. '"' .. Value .. '"'

        if I < #Table then 
            Result = Result .. "," 
        end

        Result = Result .. "\n"
    end

    return Result .. string.rep("    ", Indent - 1) .. "}"
end

local function FormatDictTable(Dict, Indent)
    Indent = Indent or 1
    local Result = "{\n"
    local Spacer = string.rep("    ", Indent)
    local Keys = {}

    for K in pairs(Dict) do 
        table.insert(Keys, K) 
    end

    table.sort(Keys)

    for i, Key in ipairs(Keys) do
        local Value = Dict[Key]
        Result = Result .. Spacer .. '["' .. Key .. '"] = {'
        local Parts = {}

        for K, V in pairs(Value) do
            table.insert(Parts, K .. " = " .. tostring(V))
        end

        Result = Result .. table.concat(Parts, ", ") .. "}"

        if i < #Keys then
            Result = Result .. ","
        end

        Result = Result .. "\n"
    end

    return Result .. string.rep("    ", Indent - 1) .. "}"
end

local ClipboardText = "return {\n" ..
    "    MutationValue = " .. FormatDictTable(MutationValue, 2) .. ",\n" ..
    "    FruitSeedValue = " .. FormatDictTable(FruitSeedValue, 2) .. ",\n" ..
    "    AllEgg = " .. FormatTable(AllEgg, 2) .. ",\n" ..
    "    SeedStock = " .. FormatTable(SeedStock, 2) .. ",\n" ..
    "    GearStock = " .. FormatTable(GearStock, 2) .. ",\n" ..
    "    NightStock = " .. FormatTable(NightStock, 2) .. ",\n" ..
    "    EventStock = " .. FormatTable(EventStock, 2) .. "\n" ..
"}"

setclipboard(ClipboardText)
