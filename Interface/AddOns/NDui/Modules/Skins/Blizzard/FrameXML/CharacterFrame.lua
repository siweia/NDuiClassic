local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)
	B.ReskinRotationButtons(CharacterModelFrame)
	B.ReskinDropDown(PlayerStatFrameLeftDropDown)
	B.ReskinDropDown(PlayerStatFrameRightDropDown)
	B.ReskinDropDown(PlayerTitleDropDown)
	PlayerTitleDropDownText:SetPoint("LEFT", 27, 2)

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

	B.StripTextures(PaperDollFrame)
	B.StripTextures(CharacterAttributesFrame)
	local bg = B.CreateBDFrame(CharacterAttributesFrame, .25)
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
		slot.SetHighlightTexture = B.Dummy
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = B.CreateBDFrame(slot, .25)
	end

	B.StripTextures(CharacterAmmoSlot)
	CharacterAmmoSlotIconTexture:SetTexCoord(.08, .92, .08, .92)
	CharacterAmmoSlot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.CreateBDFrame(CharacterAmmoSlot, .25)

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

	-- needs review
	for _, direc in pairs({"Left", "Right"}) do
		for i = 1, 6 do
			local frameName = "PlayerStatFrame"..direc..i
			local label = _G[frameName.."Label"]
			local text = _G[frameName.."StatText"]
			label:SetFontObject(Game13Font)
			text:SetFontObject(Game13Font)
		end
	end

	-- SkillFrame
	B.StripTextures(SkillFrame)
	B.ReskinScroll(SkillListScrollFrameScrollBar)
	B.Reskin(SkillFrameCancelButton)
	B.ReskinCollapse(SkillFrameCollapseAllButton)
	B.StripTextures(SkillFrameExpandButtonFrame)
	B.ReskinScroll(SkillDetailScrollFrame.ScrollBar)
	B.CreateBDFrame(SkillDetailScrollFrame, .25)
	SkillDetailStatusBarBorder:SetAlpha(0)
	SkillDetailStatusBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(SkillDetailStatusBar, .25)

	for i = 1, 12 do
		B.ReskinCollapse(_G["SkillTypeLabel"..i])
		B.CreateBDFrame(_G["SkillRankFrame"..i], .25)
		_G["SkillRankFrame"..i.."Border"]:SetAlpha(0)
		_G["SkillRankFrame"..i.."Bar"]:SetTexture(DB.bdTex)
	end

	hooksecurefunc("SkillFrame_SetStatusBar", function(statusBarID, skillIndex)
		local _, _, _, _, numTempPoints, _, _, _, stepCost, rankCost = GetSkillLineInfo(skillIndex)
		local statusBar = _G["SkillRankFrame"..statusBarID]
		if not stepCost and not (rankCost or (numTempPoints > 0)) then
			statusBar:SetStatusBarColor(0, .6, 1, .5)
		end
	end)

	-- PetFrame
	B.StripTextures(PetPaperDollFrame)
	PetPaperDollCloseButton:Hide()
	B.StripTextures(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(PetPaperDollFrameExpBar, .25)
	B.StripTextures(PetAttributesFrame)
	B.CreateBDFrame(PetAttributesFrame, .25)
	B.ReskinRotationButtons(PetModelFrame)

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
	B.CreateBDFrame(PetPaperDollPetInfo)
	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updateHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updateHappiness)

	-- PVP
	B.StripTextures(PVPFrame)

	for i = 1, 3 do
		local tName = "PVPTeam"..i
		B.StripTextures(_G[tName])
		B.CreateBDFrame(_G[tName.."Background"], .25)
	end
end)