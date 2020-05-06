local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if NDuiDB["Bags"]["Enable"] then return end
	if not NDuiDB["Skins"]["DefaultBags"] then return end

	BankFrame.CloseButton = BankCloseButton
	B.ReskinPortraitFrame(BankFrame, 10, -10, -32, 70)
	B.Reskin(BankFramePurchaseButton)
	BankSlotsFrame:DisableDrawLayer("BORDER")
	BankPortraitTexture:Hide()

	local function styleBankButton(bu)
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		bu.bg = B.CreateBDFrame(bu, .25)

		local searchOverlay = bu.searchOverlay
		if searchOverlay then
			searchOverlay:SetPoint("TOPLEFT", -C.mult, C.mult)
			searchOverlay:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
		end
	end

	for i = 1, NUM_BANKGENERIC_SLOTS do
		styleBankButton(_G["BankFrameItem"..i])
	end

	for i = 1, NUM_BANKBAGSLOTS do
		styleBankButton(BankSlotsFrame["Bag"..i])
	end

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.bg then return end

		local container = button:GetParent():GetID()
		local buttonID = button:GetID()
		if button.isBag then container = -4 end

		local texture, _, _, quality = GetContainerItemInfo(container, buttonID)
		if texture and quality and quality > 1 then
			local color = DB.QualityColors[quality]
			button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			button.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)
end)