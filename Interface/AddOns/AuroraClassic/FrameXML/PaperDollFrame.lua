local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = C.r, C.g, C.b

	F.StripTextures(PaperDollFrame)
	F.StripTextures(CharacterAttributesFrame)
	local bg = F.CreateBDFrame(CharacterAttributesFrame, .25)
	bg:SetPoint("BOTTOMRIGHT", 0, -8)

	-- [[ Item buttons ]]

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]

		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = F.dummy
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = F.CreateBDFrame(slot, .25)
	end

	F.StripTextures(CharacterAmmoSlot)
	CharacterAmmoSlotIconTexture:SetTexCoord(.08, .92, .08, .92)
	CharacterAmmoSlot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	F.CreateBDFrame(CharacterAmmoSlot, .25)

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		local icon = button.icon
		if icon then icon:SetShown(button.hasItem) end
	end)

	for i = 1, 5 do
		local bu = _G["MagicResFrame"..i]
		bu:SetSize(25, 25)
		local icon = bu:GetRegions()
		local a, b, _, _, _, _, c, d = icon:GetTexCoord()
		icon:SetTexCoord(a+.2, c-.2, b+.018, d-.018)
	end

	-- SkillFrame
	F.StripTextures(SkillFrame)
	F.ReskinScroll(SkillListScrollFrameScrollBar)
	F.Reskin(SkillFrameCancelButton)
	F.ReskinExpandOrCollapse(SkillFrameCollapseAllButton)
	F.StripTextures(SkillFrameExpandButtonFrame)
	F.ReskinScroll(SkillDetailScrollFrame.ScrollBar)
	F.CreateBDFrame(SkillDetailScrollFrame, .25)
	SkillDetailStatusBarBorder:SetAlpha(0)
	SkillDetailStatusBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(SkillDetailStatusBar, .25)

	for i = 1, 12 do
		F.ReskinExpandOrCollapse(_G["SkillTypeLabel"..i])
		F.CreateBDFrame(_G["SkillRankFrame"..i], .25)
		_G["SkillRankFrame"..i.."Border"]:SetAlpha(0)
		_G["SkillRankFrame"..i.."Bar"]:SetTexture(C.media.backdrop)
	end

	hooksecurefunc("SkillFrame_SetStatusBar", function(statusBarID, skillIndex)
		local _, _, _, _, numTempPoints, _, _, _, stepCost, rankCost = GetSkillLineInfo(skillIndex)
		local statusBar = _G["SkillRankFrame"..statusBarID]
		if not stepCost and not (rankCost or (numTempPoints > 0)) then
			statusBar:SetStatusBarColor(0, .6, 1, .5)
		end
	end)

	-- PetFrame
	F.StripTextures(PetPaperDollFrame)
	PetPaperDollCloseButton:Hide()
	F.StripTextures(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(PetPaperDollFrameExpBar, .25)
	F.StripTextures(PetAttributesFrame)
	F.CreateBDFrame(PetAttributesFrame, .25)
	F.ReskinRotationButtons(PetModelFrame)

	for i = 1, 5 do
		local bu = _G["PetMagicResFrame"..i]
		bu:SetSize(25, 25)
		local icon = bu:GetRegions()
		local a, b, _, _, _, _, c, d = icon:GetTexCoord()
		icon:SetTexCoord(a+.2, c-.2, b+.018, d-.018)
	end

	local function updateHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not happiness or not isHunterPet then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(.41, .53, .06, .3)
		elseif happiness == 2 then
			texture:SetTexCoord(.22, .345, .06, .3)
		elseif happiness == 3 then
			texture:SetTexCoord(.04, .15, .06, .3)
		end
	end

	PetPaperDollPetInfo:GetRegions():SetTexCoord(.04, .15, .06, .3)
	F.CreateBDFrame(PetPaperDollPetInfo)
	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updateHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updateHappiness)

	-- HonorFrame
	F.StripTextures(HonorFrame)
end)