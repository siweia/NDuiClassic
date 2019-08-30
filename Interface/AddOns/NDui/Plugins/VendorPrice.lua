local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local f = CreateFrame("Frame")

local function SetBagItemGlow(bagId, slot)
	local item = nil
	if IsAddOnLoaded("OneBag3") then
		item = _G["OneBagFrameBag"..bagId.."Item"..slot]
	else
		for i = 1, NUM_CONTAINER_FRAMES, 1 do
			local frame = _G["ContainerFrame"..i]
			if frame:GetID() == bagId and frame:IsShown() then
				item = _G["ContainerFrame"..i.."Item"..(GetContainerNumSlots(bagId) + 1 - slot)]
			end
		end
	end
	if item then
		item.NewItemTexture:SetAtlas("bags-glow-orange")
		item.NewItemTexture:Show()
		item.flashAnim:Play()
		item.newitemglowAnim:Play()
	end
end

local function GlowCheapestGrey()
	local lastPrice = nil
	local bagNum = nil
	local slotNum = nil
	for bag = 0, NUM_BAG_SLOTS do
		for bagSlot = 1, GetContainerNumSlots(bag) do
			local itemid = GetContainerItemID(bag, bagSlot)
			if itemid then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
				itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID,
				isCraftingReagent = GetItemInfo(itemid)
				if itemRarity == 0 and vendorPrice > 0 then
					local _, itemCount = GetContainerItemInfo(bag, bagSlot)
					local totalVendorPrice = vendorPrice * itemCount
					if lastPrice == nil then
						lastPrice = totalVendorPrice
						bagNum = bag
						slotNum = bagSlot
					elseif lastPrice > totalVendorPrice then
						lastPrice = totalVendorPrice
						bagNum = bag
						slotNum = bagSlot
					end
				end
			end
		end
	end
	if bagNum and slotNum then
		SetBagItemGlow(bagNum, slotNum)
	end
end

function f:OnEvent(event, key, state)
	if key == "LCTRL" and state == 1 then
		local bagOpen = false
		if IsAddOnLoaded("OneBag3") then
			bagOpen = OneBagFrame:IsShown()
		else
			for bag = 0, NUM_BAG_SLOTS do
				if IsBagOpen(bag) then
					bagOpen = true
					break
				end
			end
		end
		if bagOpen then
			GlowCheapestGrey()
		end
	end
end

local function SetGameToolTipPrice(tt)
	local container = GetMouseFocus()
	if container and container.GetName then -- Auctionator sanity check
		-- price is already shown at vendor; still allow showing price for tradeskill items
		if not MerchantFrame:IsShown() or container:GetName():find("TradeSkill") then
			local itemLink = select(2, tt:GetItem())
			if itemLink then
				local itemSellPrice = select(11, GetItemInfo(itemLink))
				if itemSellPrice and itemSellPrice > 0 then
					local name = container:GetName()
					local object = container:GetObjectType()
					local count
					if object == "Button" then -- ContainerFrameItem, QuestInfoItem, PaperDollItem
						count = container.count
					elseif object == "CheckButton" then -- MailItemButton or ActionButton
						count = container.count or tonumber(container.Count:GetText())
					end
					local cost = (type(count) == "number" and count or 1) * itemSellPrice
					SetTooltipMoney(tt, cost, nil, SELL_PRICE_TEXT)
				end
			end
		end
	end
end

local function SetItemRefToolTipPrice(tt)
	local itemLink = select(2, tt:GetItem())
	if itemLink then
		local itemSellPrice = select(11, GetItemInfo(itemLink))
		if itemSellPrice and itemSellPrice > 0 then
			SetTooltipMoney(tt, itemSellPrice, nil, SELL_PRICE_TEXT)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetItemRefToolTipPrice)
f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:SetScript("OnEvent", f.OnEvent)
