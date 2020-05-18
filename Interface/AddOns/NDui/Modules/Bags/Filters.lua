local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS

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
	if not NDuiDB["Bags"]["FilterJunk"] then return end
	return (item.rarity == LE_ITEM_QUALITY_POOR or NDuiADB["CustomJunkList"][item.id]) and item.sellPrice and item.sellPrice > 0
end

local function isItemAmmo(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterAmmo"] then return end
	if DB.MyClass == "HUNTER" then
		return item.equipLoc == "INVTYPE_AMMO" or module.BagsType[item.bagID] == -1
	elseif DB.MyClass == "WARLOCK" then
		return item.id == 6265 or module.BagsType[item.bagID] == 1
	end
end

local function isItemEquipment(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterEquipment"] then return end
	return item.level and item.rarity > LE_ITEM_QUALITY_POOR and (item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
end

local function isItemConsumble(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterConsumble"] then return end
	if isCustomFilter(item) == false then return end
	return isCustomFilter(item) or (item.classID and (item.classID == LE_ITEM_CLASS_CONSUMABLE or item.classID == LE_ITEM_CLASS_ITEM_ENHANCEMENT))
end

local function isItemLegendary(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterLegendary"] then return end
	return item.rarity == LE_ITEM_QUALITY_LEGENDARY
end

local function isItemFavourite(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterFavourite"] then return end
	return item.id and NDuiDB["Bags"]["FavouriteItems"][item.id]
end

local function isEmptySlot(item)
	if not NDuiDB["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture and module.BagsType[item.bagID] == 0
end

local function isItemKeyRing(item)
	return item.bagID == -2
end

local function isTradeGoods(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterGoods"] then return end
	return item.classID == LE_ITEM_CLASS_TRADEGOODS
end

local function isQuestItem(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not NDuiDB["Bags"]["FilterQuest"] then return end
	return item.isQuestItem
end

function module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isItemEquipment(item) and not isItemConsumble(item) and not isItemAmmo(item) and not isItemJunk(item) and not isItemFavourite(item) and not isEmptySlot(item) and not isTradeGoods(item) and not isQuestItem(item) end
	filters.bagAmmo = function(item) return isItemInBag(item) and isItemAmmo(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagConsumble = function(item) return isItemInBag(item) and isItemConsumble(item) end
	filters.bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isItemEquipment(item) and not isItemLegendary(item) and not isItemConsumble(item) and not isItemAmmo(item) and not isItemFavourite(item) and not isEmptySlot(item) and not isTradeGoods(item) and not isQuestItem(item) end
	filters.bankAmmo = function(item) return isItemInBank(item) and isItemAmmo(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankConsumble = function(item) return isItemInBank(item) and isItemConsumble(item) end
	filters.onlyReagent = function(item) return item.bagID == -3 end
	filters.bagFavourite = function(item) return isItemInBag(item) and isItemFavourite(item) end
	filters.bankFavourite = function(item) return isItemInBank(item) and isItemFavourite(item) end
	filters.onlyKeyring = function(item) return isItemKeyRing(item) end
	filters.bagGoods = function(item) return isItemInBag(item) and isTradeGoods(item) end
	filters.bankGoods = function(item) return isItemInBank(item) and isTradeGoods(item) end
	filters.bagQuest = function(item) return isItemInBag(item) and isQuestItem(item) end
	filters.bankQuest = function(item) return isItemInBank(item) and isQuestItem(item) end

	return filters
end