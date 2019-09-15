local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local class = select(2, UnitClass("player"))
	if class ~= "HUNTER" then return end

	F.ReskinPortraitFrame(PetStableFrame, 15, -15, -35, 73)
	F.Reskin(PetStablePurchaseButton)

	local slots = {
		PetStableCurrentPet,
		PetStableStabledPet1,
		PetStableStabledPet2,
	}

	for _, bu in pairs(slots) do
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:SetCheckedTexture(C.media.checked)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:DisableDrawLayer("BACKGROUND")

		_G[bu:GetName().."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		bu.bg = F.CreateBDFrame(bu, .25)
	end

	hooksecurefunc("PetStable_Update", function()
		for i = 1, 2 do
			local bu = _G["PetStableStabledPet"..i]
			if i <= GetNumStableSlots() then
				bu.bg:SetBackdropBorderColor(0, 0, 0)
			else
				bu.bg:SetBackdropBorderColor(1, 0, 0)
			end
		end
	end)
end)