local F, C = unpack(select(2, ...))

C.themes["Blizzard_InspectUI"] = function()
	F.StripTextures(InspectModelFrame, true)

	-- Character
	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]

		F.StripTextures(slot)
		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = F.CreateBDFrame(slot, .25)
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		local icon = button.icon
		if icon then icon:SetShown(button.hasItem) end
	end)

	F.ReskinPortraitFrame(InspectFrame, 15, -15, -35, 73)
	F.StripTextures(InspectPaperDollFrame)
	F.StripTextures(InspectHonorFrame)

	for i = 1, 2 do
		F.ReskinTab(_G["InspectFrameTab"..i])
	end
end