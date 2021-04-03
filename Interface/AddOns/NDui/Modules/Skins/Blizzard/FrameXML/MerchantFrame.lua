local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(MerchantFrame)
--	B.ReskinDropDown(MerchantFrameLootFilter)
	B.StripTextures(MerchantPrevPageButton)
	B.ReskinArrow(MerchantPrevPageButton, "left")
	B.StripTextures(MerchantNextPageButton)
	B.ReskinArrow(MerchantNextPageButton, "right")
	MerchantMoneyInset:Hide()
	MerchantMoneyBg:Hide()
	MerchantNameText:SetDrawLayer("ARTWORK")
	--MerchantExtraCurrencyBg:SetAlpha(0)
	--MerchantExtraCurrencyInset:SetAlpha(0)
	BuybackBG:SetAlpha(0)

	MerchantFrameTab1:ClearAllPoints()
	MerchantFrameTab1:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 50, -14)
	MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", -15, 0)

	for i = 1, 2 do
		B.ReskinTab(_G["MerchantFrameTab"..i])
	end

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		local item = _G["MerchantItem"..i]
		local name = item.Name
		local button = item.ItemButton
		local icon = button.icon
		local moneyFrame = _G["MerchantItem"..i.."MoneyFrame"]

		B.StripTextures(item)
		B.CreateBDFrame(item, .25)

		B.StripTextures(button)
		button.IconBorder:SetAlpha(0)
		button:ClearAllPoints()
		button:SetPoint("LEFT", item, 4, 0)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		B.ReskinIcon(icon)
		icon:SetInside()
		name:SetFontObject(Game12Font)
		name:SetPoint("LEFT", button, "RIGHT", 2, 9)

		moneyFrame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
		for j = 1, 3 do
			local currency = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j]
			local texture = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Texture"]
			currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
			B.ReskinIcon(texture)
		end
	end

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
		local numMerchantItems = GetMerchantNumItems()
		for i = 1, MERCHANT_ITEMS_PER_PAGE do
			local index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i
			if index <= numMerchantItems then
				local _, _, price, _, _, _, extendedCost = GetMerchantItemInfo(index)
				if extendedCost and (price <= 0) then
					_G["MerchantItem"..i.."AltCurrencyFrame"]:SetPoint("BOTTOMLEFT", "MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 35)
				end

				local bu = _G["MerchantItem"..i.."ItemButton"]
				local name = _G["MerchantItem"..i.."Name"]
				if bu.link then
					local _, _, quality = GetItemInfo(bu.link)
					if quality then
						local r, g, b = GetItemQualityColor(quality)
						name:SetTextColor(r, g, b)
					else
						name:SetTextColor(1, 1, 1)
					end
				else
					name:SetTextColor(1, 1, 1)
				end
			end
		end

		local name = GetBuybackItemLink(GetNumBuybackItems())
		if name then
			local _, _, quality = GetItemInfo(name)
			local r, g, b = GetItemQualityColor(quality or 1)

			MerchantBuyBackItemName:SetTextColor(r, g, b)
		end
	end)

	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			local itemLink = GetBuybackItemLink(i)
			local name = _G["MerchantItem"..i.."Name"]

			if itemLink then
				local _, _, quality = GetItemInfo(itemLink)
				local r, g, b = GetItemQualityColor(quality)

				name:SetTextColor(r, g, b)
			else
				name:SetTextColor(1, 1, 1)
			end
		end
	end)

	MerchantBuyBackItemSlotTexture:SetAlpha(0)
	MerchantBuyBackItemNameFrame:Hide()
	MerchantBuyBackItemItemButton:SetNormalTexture("")
	MerchantBuyBackItemItemButton:SetPushedTexture("")
	MerchantBuyBackItemItemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	MerchantBuyBackItemItemButton:GetHighlightTexture():SetAllPoints(MerchantBuyBackItemItemButtonIconTexture)
	MerchantBuyBackItemItemButton.IconBorder:SetAlpha(0)

	B.CreateBDFrame(MerchantBuyBackItemItemButton, 0)
	B.CreateBDFrame(MerchantBuyBackItem, .25)

	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
	MerchantBuyBackItemItemButtonIconTexture:SetPoint("TOPLEFT", C.mult, -C.mult)
	MerchantBuyBackItemItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

	MerchantBuyBackItemName:SetHeight(25)
	MerchantBuyBackItemName:ClearAllPoints()
	MerchantBuyBackItemName:SetPoint("LEFT", MerchantBuyBackItemSlotTexture, "RIGHT", -5, 8)

	local function reskinMerchantInteract(button)
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.CreateBDFrame(button)
	end

	reskinMerchantInteract(MerchantGuildBankRepairButton)
	MerchantGuildBankRepairButtonIcon:SetTexCoord(.595, .8075, .05, .52)

	reskinMerchantInteract(MerchantRepairAllButton)
	MerchantRepairAllIcon:SetTexCoord(.31375, .53, .06, .52)

	reskinMerchantInteract(MerchantRepairItemButton)
	local ic = MerchantRepairItemButton:GetRegions()
	ic:SetTexture("Interface\\Icons\\INV_Hammer_20")
	ic:SetTexCoord(unpack(DB.TexCoord))

	hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
		for i = 1, MAX_MERCHANT_CURRENCIES do
			local bu = _G["MerchantToken"..i]
			if bu and not bu.reskinned then
				local icon = _G["MerchantToken"..i.."Icon"]
				local count = _G["MerchantToken"..i.."Count"]
				count:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 0)
				B.ReskinIcon(icon)

				bu.reskinned = true
			end
		end
	end)
end)