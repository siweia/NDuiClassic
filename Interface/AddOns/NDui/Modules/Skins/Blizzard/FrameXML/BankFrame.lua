local _, ns = ...
local B, C, L, DB = unpack(ns)

local function styleBankButton(bu)
	bu:SetNormalTexture("")
	bu:SetPushedTexture("")
	bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	bu.searchOverlay:SetOutside()

	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.bg = B.CreateBDFrame(bu.icon, .25)
	B.ReskinIconBorder(bu.IconBorder)

	local questTexture = bu.IconQuestTexture
	if questTexture then
		questTexture:SetDrawLayer("BACKGROUND")
		questTexture:SetSize(1, 1)
	end
end

tinsert(C.defaultThemes, function()
	if C.db["Bags"]["Enable"] then return end
	if not C.db["Skins"]["DefaultBags"] then return end

	BankFrame.CloseButton = BankCloseButton
	B.ReskinPortraitFrame(BankFrame, 25, -10, 0, 70)
	B.Reskin(BankFramePurchaseButton)
	BankSlotsFrame:DisableDrawLayer("BORDER")
	BankPortraitTexture:Hide()

	for i = 1, NUM_BANKGENERIC_SLOTS do
		styleBankButton(_G["BankFrameItem"..i])
	end

	for i = 1, NUM_BANKBAGSLOTS do
		styleBankButton(BankSlotsFrame["Bag"..i])
	end

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag and button.IconQuestTexture:IsShown() then
			button.IconBorder:SetVertexColor(1, 1, 0)
		end
	end)
end)