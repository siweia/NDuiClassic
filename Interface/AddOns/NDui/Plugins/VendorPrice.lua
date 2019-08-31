------------------------------
-- VendorPrice 1.1.4, Ketho
------------------------------
local select, tonumber, type, strfind = select, tonumber, type, string.find
local MerchantFrame = MerchantFrame
local GetMouseFocus, GetItemInfo, SetTooltipMoney = GetMouseFocus, GetItemInfo, SetTooltipMoney
local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)

local function SetGameToolTipPrice(tt)
	local container = GetMouseFocus()
	if container and container.GetName then -- Auctionator sanity check
		local name = container:GetName()
		-- price is already shown at vendor for bag items
		if not MerchantFrame:IsShown() or strfind(name, "Character") or strfind(name, "TradeSkill") then
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
GameTooltip:HookScript("OnTooltipSetItem", SetGameToolTipPrice)

local function SetItemRefToolTipPrice(tt)
	local itemLink = select(2, tt:GetItem())
	if itemLink then
		local itemSellPrice = select(11, GetItemInfo(itemLink))
		if itemSellPrice and itemSellPrice > 0 then
			SetTooltipMoney(tt, itemSellPrice, nil, SELL_PRICE_TEXT)
		end
	end
end
ItemRefTooltip:HookScript("OnTooltipSetItem", SetItemRefToolTipPrice)