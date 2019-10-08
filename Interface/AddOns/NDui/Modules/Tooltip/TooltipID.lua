local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local strmatch, format, tonumber, select, strfind = string.match, string.format, tonumber, select, string.find
local UnitAura, GetItemCount, GetItemInfo, GetUnitName, GetCurrencyListLink = UnitAura, GetItemCount, GetItemInfo, GetUnitName, GetCurrencyListLink
local GetMouseFocus = GetMouseFocus
local BAGSLOT, BANK = BAGSLOT, BANK
local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)

local types = {
	spell = SPELLS.."ID:",
	item = ITEMS.."ID:",
	quest = QUESTS_LABEL.."ID:",
	talent = TALENT.."ID:",
	achievement = ACHIEVEMENTS.."ID:",
	currency = CURRENCY.."ID:",
	azerite = L["Trait"].."ID:",
}

local function setupMoneyString(amount)
	local module = B:GetModule("Infobar")
	if module then
		return module:GetMoneyString(amount, true)
	end
end

function TT:UpdateItemSellPrice()
	local frame = GetMouseFocus()
	if frame and frame.GetName then
		local name = frame:GetName()
		if not MerchantFrame:IsShown() or name and (strfind(name, "Character") or strfind(name, "TradeSkill")) then
			local link = select(2, self:GetItem())
			if link then
				local price = select(11, GetItemInfo(link))
				if price and price > 0 then
					local object = frame:GetObjectType()
					local count
					if object == "Button" then -- ContainerFrameItem, QuestInfoItem, PaperDollItem
						count = frame.count
					elseif object == "CheckButton" then -- MailItemButton or ActionButton
						count = frame.count or tonumber(frame.Count:GetText())
					end

					local cost = (tonumber(count) or 1) * price
					self:AddDoubleLine(SELL_PRICE_TEXT, setupMoneyString(cost), nil,nil,nil, 1,1,1)
				end
			end
		end
	end
end

function TT:AddLineForID(id, linkType, noadd)
	for i = 1, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and text == linkType then return end
	end
	if not noadd then self:AddLine(" ") end

	if linkType == types.item then
		TT.UpdateItemSellPrice(self)

		local bagCount = GetItemCount(id)
		local bankCount = GetItemCount(id, true) - GetItemCount(id)
		local itemStackCount = select(8, GetItemInfo(id))
		if bankCount > 0 then
			self:AddDoubleLine(BAGSLOT.."/"..BANK..":", DB.InfoColor..bagCount.."/"..bankCount)
		elseif bagCount > 0 then
			self:AddDoubleLine(BAGSLOT..":", DB.InfoColor..bagCount)
		end
		if itemStackCount and itemStackCount > 1 then
			self:AddDoubleLine(L["Stack Cap"]..":", DB.InfoColor..itemStackCount)
		end
	end

	self:AddDoubleLine(linkType, format(DB.InfoColor.."%s|r", id))
	self:Show()
end

function TT:SetHyperLinkID(link)
	local linkType, id = strmatch(link, "^(%a+):(%d+)")
	if not linkType or not id then return end

	if linkType == "spell" or linkType == "enchant" or linkType == "trade" then
		TT.AddLineForID(self, id, types.spell)
	elseif linkType == "talent" then
		TT.AddLineForID(self, id, types.talent, true)
	elseif linkType == "quest" then
		TT.AddLineForID(self, id, types.quest)
	elseif linkType == "achievement" then
		TT.AddLineForID(self, id, types.achievement)
	elseif linkType == "item" then
		TT.AddLineForID(self, id, types.item)
	elseif linkType == "currency" then
		TT.AddLineForID(self, id, types.currency)
	end
end

function TT:SetItemID()
	local link = select(2, self:GetItem())
	if link then
		local id = strmatch(link, "item:(%d+):")
		local keystone = strmatch(link, "|Hkeystone:([0-9]+):")
		if keystone then id = tonumber(keystone) end
		if id then TT.AddLineForID(self, id, types.item) end
	end
end

function TT:UpdateSpellCaster(...)
	local unitCaster = select(7, UnitAura(...))
	if unitCaster then
		local name = GetUnitName(unitCaster, true)
		local hexColor = B.HexRGB(B.UnitColor(unitCaster))
		self:AddDoubleLine(L["From"]..":", hexColor..name)
		self:Show()
	end
end

function TT:SetupTooltipID()
	if NDuiDB["Tooltip"]["HideAllID"] then return end

	-- Update all
	hooksecurefunc(GameTooltip, "SetHyperlink", TT.SetHyperLinkID)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", TT.SetHyperLinkID)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		local id = select(10, UnitAura(...))
		if id then TT.AddLineForID(self, id, types.spell) end
	end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		local id = select(2, self:GetSpell())
		if id then TT.AddLineForID(self, id, types.spell) end
	end)
	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(strmatch(link, "spell:(%d+)"))
		if id then TT.AddLineForID(ItemRefTooltip, id, types.spell) end
	end)

	-- Items
	GameTooltip:HookScript("OnTooltipSetItem", TT.SetItemID)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.SetItemID)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.SetItemID)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", TT.SetItemID)
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", TT.SetItemID)
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", TT.SetItemID)

	-- Spell caster
	hooksecurefunc(GameTooltip, "SetUnitAura", TT.UpdateSpellCaster)
end