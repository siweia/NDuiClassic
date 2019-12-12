local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)
	F.ReskinRotationButtons(CharacterModelFrame)

	local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES or 5

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G["CharacterFrameTab"..i]
		tab.bg = F.ReskinTab(tab)
		if i == 1 then
			tab:SetPoint("CENTER", CharacterFrame, "BOTTOMLEFT", 60, 59)
		else
			tab:SetPoint("LEFT", _G["CharacterFrameTab"..(i-1)], "RIGHT", -14, 0)
		end
		local hl = _G["CharacterFrameTab"..i.."HighlightTexture"]
		hl:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
	end

	HonorFrameProgressBar:SetWidth(320)
	HonorFrameProgressBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(HonorFrameProgressBar, .25)
	HonorFrameProgressBar:SetPoint("TOPLEFT", 22, -73)

	local bg = F.CreateBDFrame(HonorFrame, .25)
	bg:SetPoint("TOPLEFT", 21, -105)
	bg:SetPoint("BOTTOMRIGHT", -41, 80)
end)