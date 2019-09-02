local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationListScrollFrame:GetRegions():Hide()
	select(2, ReputationListScrollFrame:GetRegions()):Hide()

	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 2, -28)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local bar = _G["ReputationBar"..i]
			if bar and not bar.styled then
				F.StripTextures(bar)
				bar:SetStatusBarTexture(C.media.backdrop)
				F.CreateBD(bar, .25)

				bar.styled = true
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		F.ReskinExpandOrCollapse(_G["ReputationHeader"..i])
	end

	F.StripTextures(ReputationFrame)
	F.StripTextures(ReputationDetailFrame)
	F.CreateBD(ReputationDetailFrame)
	F.CreateSD(ReputationDetailFrame)
	F.ReskinClose(ReputationDetailCloseButton)
	F.ReskinCheck(ReputationDetailAtWarCheckBox)
	F.ReskinCheck(ReputationDetailInactiveCheckBox)
	F.ReskinCheck(ReputationDetailMainScreenCheckBox)
	F.ReskinScroll(ReputationListScrollFrameScrollBar)
	select(3, ReputationDetailFrame:GetRegions()):Hide()
end)