local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

function S:PlayerStats()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	local statPanel = CreateFrame("Frame", "NDuiStatePanel", PaperDollFrame)
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
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scrollBar = self.ScrollBar
		local step = delta*25
		if IsShiftKeyDown() then
			step = step*6
		end
		scrollBar:SetValue(scrollBar:GetValue() - step)
	end)

	local function CreateStatLine(parent, index)
		local frame = CreateFrame("Frame", "$parentRow"..index, parent, "StatFrameTemplate")
		frame:SetWidth(180)
		frame:SetPoint("TOP", parent, "BOTTOM", 0, -2 - (index-1)*16)
		local background = frame:CreateTexture(nil, "BACKGROUND")
		background:SetAtlas("UI-Character-Info-Line-Bounce", true)
		background:SetAlpha(.3)
		background:SetPoint("CENTER")
		background:SetShown(index%2 == 0)

		return frame
	end

	local function SetCharacterStats(statsTable, category)
		if category == PLAYERSTAT_BASE_STATS then
			PaperDollFrame_SetStat(statsTable[1], 1)
			PaperDollFrame_SetStat(statsTable[2], 2)
			PaperDollFrame_SetStat(statsTable[3], 3)
			PaperDollFrame_SetStat(statsTable[4], 4)
			PaperDollFrame_SetStat(statsTable[5], 5)
			PaperDollFrame_SetArmor(statsTable[6])
		elseif category == PLAYERSTAT_DEFENSES then
			PaperDollFrame_SetArmor(statsTable[1])
			PaperDollFrame_SetDefense(statsTable[2])
			PaperDollFrame_SetDodge(statsTable[3])
			PaperDollFrame_SetParry(statsTable[4])
			PaperDollFrame_SetBlock(statsTable[5])
			PaperDollFrame_SetResilience(statsTable[6])
		elseif category == PLAYERSTAT_MELEE_COMBAT then
			PaperDollFrame_SetDamage(statsTable[1])
			statsTable[1]:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
			PaperDollFrame_SetAttackSpeed(statsTable[2])
			PaperDollFrame_SetAttackPower(statsTable[3])
			PaperDollFrame_SetRating(statsTable[4], CR_HIT_MELEE)
			PaperDollFrame_SetMeleeCritChance(statsTable[5])
			PaperDollFrame_SetExpertise(statsTable[6])
		elseif category == PLAYERSTAT_RANGED_COMBAT then
			PaperDollFrame_SetRangedDamage(statsTable[1])
			statsTable[1]:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
			PaperDollFrame_SetRangedAttackSpeed(statsTable[2])
			PaperDollFrame_SetRangedAttackPower(statsTable[3])
			PaperDollFrame_SetRating(statsTable[4], CR_HIT_RANGED)
			PaperDollFrame_SetRangedCritChance(statsTable[5])
			statsTable[6]:SetAlpha(0)
		elseif category == PLAYERSTAT_SPELL_COMBAT then
			PaperDollFrame_SetSpellBonusDamage(statsTable[1])
			statsTable[1]:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
			PaperDollFrame_SetSpellBonusHealing(statsTable[2])
			PaperDollFrame_SetRating(statsTable[3], CR_HIT_SPELL)
			PaperDollFrame_SetSpellCritChance(statsTable[4])
			statsTable[4]:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
			PaperDollFrame_SetSpellHaste(statsTable[5])
			PaperDollFrame_SetManaRegen(statsTable[6])
		end
	end

	local function CreateStatHeader(parent, index, category)
		local header = CreateFrame("Frame", "NDuiStatCategory"..index, parent, "CharacterStatFrameCategoryTemplate")
		header:SetPoint("TOP", 0, -25 - (index-1)*150)
		header.Background:Hide()
		header.Title:SetText(category)
		header.Title:SetTextColor(cr, cg, cb)
		local line = header:CreateTexture(nil, "ARTWORK")
		line:SetSize(180, C.mult)
		line:SetPoint("BOTTOM", 0, 5)
		line:SetColorTexture(1, 1, 1, .25)
		local statsTable = {}
		for i = 1, 6 do
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
	dataTable[4] = CreateStatHeader(stat, 4, PLAYERSTAT_SPELL_COMBAT)
	dataTable[5] = CreateStatHeader(stat, 5, PLAYERSTAT_RANGED_COMBAT)

	local function UpdateStats()
		if not statPanel:IsShown() then return end
		for i = 1, 5 do
			SetCharacterStats(dataTable[i], dataTable[i].category)
		end
	end
	hooksecurefunc("ToggleCharacter", UpdateStats)
	PaperDollFrame:HookScript("OnEvent", UpdateStats)

	-- Expand button
	local bu = CreateFrame("Button", nil, PaperDollFrame)
	bu:SetPoint("RIGHT", CharacterFrameCloseButton, "LEFT", -3, 0)
	B.ReskinArrow(bu, "right")
	bu.collapse = not C.db["Skins"]["ExpandStat"]

	local function ToggleMagicRes(collapse)
		if collapse then
			CharacterResistanceFrame:ClearAllPoints()
			CharacterResistanceFrame:SetPoint("TOPRIGHT", PaperDollFrame, "TOPLEFT", 297, -77)
			CharacterResistanceFrame:SetParent(PaperDollFrame)

			for i = 1, 5 do
				local bu = _G["MagicResFrame"..i]
				if i > 1 then
					bu:ClearAllPoints()
					bu:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM")
				end
			end
		else
			CharacterResistanceFrame:ClearAllPoints()
			CharacterResistanceFrame:SetPoint("TOPLEFT", stat, 25, -5)
			CharacterResistanceFrame:SetParent(stat)

			for i = 1, 5 do
				local bu = _G["MagicResFrame"..i]
				if i > 1 then
					bu:ClearAllPoints()
					bu:SetPoint("LEFT", _G["MagicResFrame"..(i-1)], "RIGHT", 5, 0)
				end
			end
		end
	end

	local function ToggleStatPanel(collapse)
		if collapse then
			B.SetupArrow(bu.__texture, "right")
			CharacterAttributesFrame:Show()
			statPanel:Hide()
		else
			B.SetupArrow(bu.__texture, "down")
			CharacterAttributesFrame:Hide()
			statPanel:Show()
		end
		ToggleMagicRes(collapse)
	end

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		C.db["Skins"]["ExpandStat"] = not C.db["Skins"]["ExpandStat"]
		ToggleStatPanel(self.collapse)
	end)

	ToggleStatPanel(not C.db["Skins"]["ExpandStat"])
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
	B.ReskinClose(frame.CloseButton, frame.bg, -2, -2)

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
	B.CreateBDFrame(BindPadMacroPopupEditBox, .25)
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
				B.CreateBDFrame(ic, .25)

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
	self:PlayerStats()
	self:WhatsTraining()
	self:RecountSkin()
	self:BindPad()
end