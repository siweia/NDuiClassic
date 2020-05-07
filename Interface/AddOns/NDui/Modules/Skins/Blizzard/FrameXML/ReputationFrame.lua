local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationListScrollFrame:GetRegions():Hide()
	select(2, ReputationListScrollFrame:GetRegions()):Hide()

	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 2, -28)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local bar = _G["ReputationBar"..i]
			local check = _G["ReputationBar"..i.."AtWarCheck"]
			if bar and not bar.styled then
				B.StripTextures(bar)
				bar:SetStatusBarTexture(DB.bdTex)
				B.CreateBD(bar, .25)

				local icon = check:GetRegions()
				icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
				icon:SetTexCoord(0, 1, 0, 1)
				icon:ClearAllPoints()
				icon:SetPoint("LEFT", check, 0, -3)

				bar.styled = true
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		B.ReskinExpandOrCollapse(_G["ReputationHeader"..i])
	end

	B.StripTextures(ReputationFrame)
	B.StripTextures(ReputationDetailFrame)
	B.SetBD(ReputationDetailFrame)
	B.ReskinClose(ReputationDetailCloseButton)
	B.ReskinCheck(ReputationDetailAtWarCheckBox)
	B.ReskinCheck(ReputationDetailInactiveCheckBox)
	B.ReskinCheck(ReputationDetailMainScreenCheckBox)
	B.ReskinScroll(ReputationListScrollFrameScrollBar)
	select(3, ReputationDetailFrame:GetRegions()):Hide()
end)