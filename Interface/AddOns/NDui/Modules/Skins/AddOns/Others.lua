local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

function S:CharacterStatsClassic()
	if not IsAddOnLoaded("CharacterStatsClassic") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b
	if CharacterStatsClassicDB.expandStat == nil then
		CharacterStatsClassicDB.expandStat = false
	end

	local leftDropDown, rightDropDown
	for i = 1, CharacterFrame:GetNumChildren() do
		local child = select(i, CharacterFrame:GetChildren())
		if child and child.leftStatsDropDown then
			B.ReskinDropDown(child.leftStatsDropDown)
			leftDropDown = child.leftStatsDropDown
		end
		if child and child.rightStatsDropDown then
			B.ReskinDropDown(child.rightStatsDropDown)
			rightDropDown = child.rightStatsDropDown
		end
	end

	if not CSC_PaperDollFrame_SetRangedHitChance then return end -- old version check

	local statPanel = CreateFrame("Frame", nil, PaperDollFrame)
	statPanel:SetSize(200, 422)
	statPanel:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -32, -15-C.mult)
	B.SetBD(statPanel)

	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = B.Dummy
	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
	scrollFrame:SetScrollChild(stat)

	local function SetCharacterStats(statsTable, category)
		if category == PLAYERSTAT_BASE_STATS then
			-- str, agility, stamina, intelect, spirit
			CSC_PaperDollFrame_SetPrimaryStats(statsTable, "player")
		elseif category == PLAYERSTAT_DEFENSES then
			-- armor, defense, dodge, parry, block
			CSC_PaperDollFrame_SetArmor(statsTable[1], "player")
			CSC_PaperDollFrame_SetDefense(statsTable[2], "player")
			CSC_PaperDollFrame_SetDodge(statsTable[3], "player")
			CSC_PaperDollFrame_SetParry(statsTable[4], "player")
			CSC_PaperDollFrame_SetBlock(statsTable[5], "player")
		elseif category == PLAYERSTAT_MELEE_COMBAT then
			-- damage, Att Power, speed, hit raiting, crit chance
			CSC_PaperDollFrame_SetDamage(statsTable[1], "player", category)
			CSC_PaperDollFrame_SetMeleeAttackPower(statsTable[2], "player")
			CSC_PaperDollFrame_SetAttackSpeed(statsTable[3], "player")
			CSC_PaperDollFrame_SetCritChance(statsTable[4], "player", category)
			CSC_PaperDollFrame_SetHitChance(statsTable[5], "player")
		elseif category == PLAYERSTAT_RANGED_COMBAT then
			CSC_PaperDollFrame_SetDamage(statsTable[1], "player", category)
			CSC_PaperDollFrame_SetRangedAttackPower(statsTable[2], "player")
			CSC_PaperDollFrame_SetRangedAttackSpeed(statsTable[3], "player")
			CSC_PaperDollFrame_SetCritChance(statsTable[4], "player", category)
			CSC_PaperDollFrame_SetRangedHitChance(statsTable[5], "player")
		elseif category == PLAYERSTAT_SPELL_COMBAT then
			-- bonus dmg, bonus healing, crit chance, mana regen, hit
			CSC_PaperDollFrame_SetSpellPower(statsTable[1], "player")
			CSC_PaperDollFrame_SetHealing(statsTable[2], "player")
			CSC_PaperDollFrame_SetManaRegen(statsTable[3], "player")
			CSC_PaperDollFrame_SetSpellCritChance(statsTable[4], "player")
			CSC_PaperDollFrame_SetSpellHitChance(statsTable[5], "player")
		end
	end

	local function CreateStatLine(parent, index)
		local frame = CreateFrame("Frame", nil, parent, "CharacterStatFrameTemplate")
		frame:SetWidth(180)
		frame:SetPoint("TOP", parent, "BOTTOM", 0, -2 - (index-1)*16)
		frame.Background:SetShown(index%2 == 1)
		return frame
	end

	local function CreateStatHeader(parent, index, category)
		local header = CreateFrame("Frame", nil, parent, "CharacterStatFrameCategoryTemplate")
		header:SetPoint("TOP", 0, -2 - (index-1)*125)
		header.Background:Hide()
		header.Title:SetText(category)
		header.Title:SetTextColor(cr, cg, cb)
		local line = header:CreateTexture(nil, "ARTWORK")
		line:SetSize(180, C.mult)
		line:SetPoint("BOTTOM", 0, 5)
		line:SetColorTexture(1, 1, 1, .25)
		local statsTable = {}
		for i = 1, 5 do
			statsTable[i] = CreateStatLine(header, i)
		end
		SetCharacterStats(statsTable, category)
		statsTable.category = category

		return statsTable
	end

	local dataTable = {}
	dataTable[1] = CreateStatHeader(stat, 1, PLAYERSTAT_BASE_STATS)
	dataTable[2] = CreateStatHeader(stat, 2, PLAYERSTAT_DEFENSES)
	dataTable[3] = CreateStatHeader(stat, 3, PLAYERSTAT_MELEE_COMBAT)
	dataTable[4] = CreateStatHeader(stat, 4, PLAYERSTAT_RANGED_COMBAT)
	dataTable[5] = CreateStatHeader(stat, 5, PLAYERSTAT_SPELL_COMBAT)

	local function UpdateStats()
		if not statPanel:IsShown() then return end
		for i = 1, 5 do
			SetCharacterStats(dataTable[i], dataTable[i].category)
		end
	end
	hooksecurefunc("ToggleCharacter", UpdateStats)
	PaperDollFrame:HookScript("OnEvent", UpdateStats)

	-- Blank space
	local frame = CreateFrame("Frame", nil, stat)
	frame:SetSize(10, 10)
	frame:SetPoint("TOP", 0, -627)

	-- Expand button
	local bu = CreateFrame("Button", nil, PaperDollFrame)
	bu:SetSize(17, 17)
	bu:SetPoint("RIGHT", CharacterFrameCloseButton, "LEFT", -3, 0)
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	B.ReskinExpandOrCollapse(bu)
	bu.bg:SetSize(17, 17)
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu.collapse = not CharacterStatsClassicDB.expandStat

	local function ToggleStatPanel(collapse)
		if collapse then
			bu:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			leftDropDown:Show()
			rightDropDown:Show()
			statPanel:Hide()
		else
			bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
			leftDropDown:Hide()
			rightDropDown:Hide()
			statPanel:Show()
		end
	end

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		CharacterStatsClassicDB.expandStat = not CharacterStatsClassicDB.expandStat
		ToggleStatPanel(self.collapse)
	end)

	ToggleStatPanel(not CharacterStatsClassicDB.expandStat)
end

function S:WhatsTraining()
	if not IsAddOnLoaded("WhatsTraining") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local done
	SpellBookFrame:HookScript("OnShow", function()
		if done then return end

		B.StripTextures(WhatsTrainingFrame)
		local bg = B.CreateBDFrame(WhatsTrainingFrameScrollBar, 1)
		bg:SetPoint("TOPLEFT", 20, 0)
		bg:SetPoint("BOTTOMRIGHT", 4, 0)
		B.ReskinScroll(WhatsTrainingFrameScrollBarScrollBar)
		B:GetModule("Tooltip").ReskinTooltip(WhatsTrainingTooltip)

		for i = 1, 22 do
			local bar = _G["WhatsTrainingFrameRow"..i.."Spell"]
			if bar and bar.icon then
				B.ReskinIcon(bar.icon)
			end
		end

		done = true
	end)
end

function S:ResetRecount()
	Recount:RestoreMainWindowPosition(797, -405, 320, 220)

	Recount.db.profile.Locked = true
	Recount:LockWindows(true)

	Recount.db.profile.MainWindowHeight = 320
	Recount.db.profile.MainWindowWidth = 220
	Recount:ResizeMainWindow()

	Recount.db.profile.MainWindow.RowHeight = 18
	Recount:BarsChanged()

	Recount.db.profile.BarTexture = "normTex"
	Recount.db.profile.Font = nil
	Recount:UpdateBarTextures()

	C.db["Skins"]["ResetRecount"] = false
end

function S:ResetRocountFont()
	for _, row in pairs(Recount.MainWindow.Rows) do
		local font, fontSize = row.LeftText:GetFont()
		row.LeftText:SetFont(font, fontSize, DB.Font[3])
		row.RightText:SetFont(font, fontSize, DB.Font[3])
	end
end

function S:RecountSkin()
	if not C.db["Skins"]["Recount"] then return end
	if not IsAddOnLoaded("Recount") then return end

	local frame = Recount_MainWindow
	B.StripTextures(frame)
	local bg = B.SetBD(frame)
	bg:SetPoint("TOPLEFT", 0, -10)
	frame.bg = bg

	local open, close = S:CreateToggle(frame)
	open:HookScript("OnClick", function()
		Recount.MainWindow:Show()
		Recount:RefreshMainWindow()
	end)
	close:HookScript("OnClick", function()
		Recount.MainWindow:Hide()
	end)

	if C.db["Skins"]["ResetRecount"] then S:ResetRecount() end
	hooksecurefunc(Recount, "ResetPositions", S.ResetRecount)

	S:ResetRocountFont()
	hooksecurefunc(Recount, "BarsChanged", S.ResetRocountFont)

	B.ReskinArrow(frame.LeftButton, "left")
	B.ReskinArrow(frame.RightButton, "right")
	B.ReskinClose(frame.CloseButton, "TOPRIGHT", frame.bg, "TOPRIGHT", -2, -2)

	-- Force to show window on init
	Recount.MainWindow:Show()
end

function S:BindPad()
	if not IsAddOnLoaded("BindPad") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	BindPadFrame.bg = B.ReskinPortraitFrame(BindPadFrame, 10, -10, -30, 70)
	for i = 1, 4 do
		B.ReskinTab(_G["BindPadFrameTab"..i])
	end
	B.ReskinScroll(BindPadScrollFrameScrollBar)
	B.ReskinCheck(BindPadFrameCharacterButton)
	B.ReskinCheck(BindPadFrameSaveAllKeysButton)
	B.ReskinCheck(BindPadFrameShowHotkeyButton)
	B.Reskin(BindPadFrameExitButton)
	B.ReskinArrow(BindPadShowLessSlotButton, "left")
	B.ReskinArrow(BindPadShowMoreSlotButton, "right")

	B.StripTextures(BindPadDialogFrame)
	B.SetBD(BindPadDialogFrame)
	B.Reskin(BindPadDialogFrame.cancelbutton)
	B.Reskin(BindPadDialogFrame.okaybutton)

	hooksecurefunc("BindPadSlot_UpdateState", function(slot)
		if slot.styled then return end

		slot:DisableDrawLayer("ARTWORK")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.icon:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(slot, .25)
		slot.border:SetTexture()

		B.StripTextures(slot.addbutton)
		local nt = slot.addbutton:GetNormalTexture()
		nt:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		nt:SetTexCoord(0, .4375, 0, .4375)

		slot.styled = true
	end)

	B.StripTextures(BindPadMacroPopupFrame)
	BindPadMacroPopupFrame:SetPoint("TOPLEFT", BindPadFrame.bg, "TOPRIGHT", 3, -40)
	B.SetBD(BindPadMacroPopupFrame)
	B.StripTextures(BindPadMacroPopupEditBox)
	B.CreateBD(BindPadMacroPopupEditBox, .25)
	B.ReskinScroll(BindPadMacroPopupScrollFrameScrollBar)
	B.Reskin(BindPadMacroPopupOkayButton)
	B.Reskin(BindPadMacroPopupCancelButton)

	hooksecurefunc("BindPadMacroPopupFrame_Update", function()
		for i = 1, 20 do
			local bu = _G["BindPadMacroPopupButton"..i]
			local ic = _G["BindPadMacroPopupButton"..i.."Icon"]

			if not bu.styled then
				bu:SetCheckedTexture(DB.textures.pushed)
				select(2, bu:GetRegions()):Hide()
				local hl = bu:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(ic)

				ic:SetPoint("TOPLEFT", C.mult, -C.mult)
				ic:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
				ic:SetTexCoord(unpack(DB.TexCoord))
				B.CreateBD(bu, .25)

				bu.styled = true
			end
		end
	end)

	B.StripTextures(BindPadBindFrame)
	B.SetBD(BindPadBindFrame)
	B.ReskinClose(BindPadBindFrameCloseButton)
	B.ReskinCheck(BindPadBindFrameForAllCharacterButton)
	B.Reskin(BindPadBindFrameUnbindButton)
	B.Reskin(BindPadBindFrameExitButton)

	B.ReskinPortraitFrame(BindPadMacroFrame, 10, -10, -30, 70)
	B.ReskinScroll(BindPadMacroFrameScrollFrameScrollBar)
	B.Reskin(BindPadMacroFrameEditButton)
	B.Reskin(BindPadMacroDeleteButton)
	B.Reskin(BindPadMacroFrameTestButton)
	B.Reskin(BindPadMacroFrameExitButton)
	B.StripTextures(BindPadMacroFrameTextBackground)
	B.CreateBDFrame(BindPadMacroFrameTextBackground, .25)
	B.StripTextures(BindPadMacroFrameSlotButton)
	B.ReskinIcon(BindPadMacroFrameSlotButtonIcon)
end

function S:LoadOtherSkins()
	self:CharacterStatsClassic()
	self:WhatsTraining()
	self:RecountSkin()
	self:BindPad()
end