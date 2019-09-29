local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")

function S:WhatsTraining()
	if not IsAddOnLoaded("WhatsTraining") then return end

	local done
	SpellBookFrame:HookScript("OnShow", function()
		if done then return end

		F.StripTextures(WhatsTrainingFrame)
		local bg = F.CreateBDFrame(WhatsTrainingFrameScrollBar, 1)
		bg:SetPoint("TOPLEFT", 20, 0)
		bg:SetPoint("BOTTOMRIGHT", 4, 0)
		F.ReskinScroll(WhatsTrainingFrameScrollBarScrollBar)
		B:GetModule("Tooltip").ReskinTooltip(WhatsTrainingTooltip)

		for i = 1, 22 do
			local bar = _G["WhatsTrainingFrameRow"..i.."Spell"]
			if bar and bar.icon then
				F.ReskinIcon(bar.icon)
			end
		end

		done = true
	end)
end