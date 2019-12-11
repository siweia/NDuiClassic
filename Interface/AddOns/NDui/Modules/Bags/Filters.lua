local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR

-- Custom filter
local CustomFilterList = {
	[37863] = false,	-- 酒吧传送器
	[141333] = true,	-- 宁神圣典
	[141446] = true,	-- 宁神书卷
	[153646] = true,	-- 静心圣典
	[153647] = true,	-- 静心书卷
	[161053] = true,	-- 水手咸饼干
}

local function isCustomFilter(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagID >= 0 and item.bagID <= 4
end

local function isItemInBank(item)
	return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
end

local function isItemJunk(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0
end

local function isItemAmmo(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if DB.MyClass == "HUNTER" then
		return item.equipLoc == "INVTYPE_AMMO" or module.BagsType[item.bagID] == -1
	elseif DB.MyClass == "WARLOCK" then
		return item.id == 6265 or module.BagsType[item.bagID] == 1
	end
end

local function isItemEquipment(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	--if NDuiDB["Bags"]["ItemSetFilter"] then
	--	return item.isInSet
	--else
		return item.level and item.rarity > LE_ITEM_QUALITY_POOR and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
	--end
end

local function isItemConsumble(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if isCustomFilter(item) == false then return end
	return isCustomFilter(item) or (item.classID and (item.classID == LE_ITEM_CLASS_CONSUMABLE or item.classID == LE_ITEM_CLASS_ITEM_ENHANCEMENT))
end

local function isItemLegendary(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.rarity == LE_ITEM_QUALITY_LEGENDARY
end

local function isItemFavourite(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.id and NDuiDB["Bags"]["FavouriteItems"][item.id]
end

local function isEmptySlot(item)
	if not NDuiDB["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture and module.BagsType[item.bagID] == 0
end

function module:GetFilters()
	local onlyBags = function(item) return isItemInBag(item) and not isItemEquipment(item) and not isItemConsumble(item) and not isItemAmmo(item) and not isItemJunk(item) and not isItemFavourite(item) and not isEmptySlot(item) end
	local bagAmmo = function(item) return isItemInBag(item) and isItemAmmo(item) end
	local bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	local bagConsumble = function(item) return isItemInBag(item) and isItemConsumble(item) end
	local bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	local onlyBank = function(item) return isItemInBank(item) and not isItemEquipment(item) and not isItemLegendary(item) and not isItemConsumble(item) and not isItemAmmo(item) and not isItemFavourite(item) and not isEmptySlot(item) end
	local bankAmmo = function(item) return isItemInBank(item) and isItemAmmo(item) end
	local bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	local bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	local bankConsumble = function(item) return isItemInBank(item) and isItemConsumble(item) end
	local onlyReagent = function(item) return item.bagID == -3 end
	local bagFavourite = function(item) return isItemInBag(item) and isItemFavourite(item) end
	local bankFavourite = function(item) return isItemInBank(item) and isItemFavourite(item) end

	return onlyBags, bagAmmo, bagEquipment, bagConsumble, bagsJunk, onlyBank, bankAmmo, bankLegendary, bankEquipment, bankConsumble, onlyReagent, bagFavourite, bankFavourite
end