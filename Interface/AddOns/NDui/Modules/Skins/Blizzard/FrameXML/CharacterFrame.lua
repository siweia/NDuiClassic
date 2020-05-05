local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)
	B.ReskinRotationButtons(CharacterModelFrame)

	local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES or 5

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G["CharacterFrameTab"..i]
		tab.bg = B.ReskinTab(tab)
		if i == 1 then
			tab:SetPoint("CENTER", CharacterFrame, "BOTTOMLEFT", 60, 59)
		end
		local hl = _G["CharacterFrameTab"..i.."HighlightTexture"]
		hl:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
	end

	HonorFrameProgressBar:SetWidth(320)
	HonorFrameProgressBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(HonorFrameProgressBar, .25)
	HonorFrameProgressBar:SetPoint("TOPLEFT", 22, -73)

	local bg = B.CreateBDFrame(HonorFrame, .25)
	bg:SetPoint("TOPLEFT", 21, -105)
	bg:SetPoint("BOTTOMRIGHT", -41, 80)
end)