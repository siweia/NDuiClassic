local F, C = unpack(select(2, ...))

C.themes["Blizzard_CraftUI"] = function()
	F.ReskinPortraitFrame(CraftFrame, 10, -10, -30, 70)
	F.ReskinScroll(CraftListScrollFrameScrollBar)
	F.ReskinScroll(CraftDetailScrollFrameScrollBar)
	F.Reskin(CraftCreateButton)
	F.Reskin(CraftCancelButton)

	F.StripTextures(CraftRankFrameBorder)
	F.StripTextures(CraftRankFrame)
	CraftRankFrame:SetStatusBarColor(C.media.backdrop)
	F.CreateBDFrame(CraftRankFrame, .25)
	CraftRankFrame:SetWidth(220)

	F.StripTextures(CraftDetailScrollChildFrame)
	F.StripTextures(CraftIcon)
	F.CreateBDFrame(CraftIcon)
	F.ReskinExpandOrCollapse(CraftCollapseAllButton)
	CraftExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	hooksecurefunc("CraftFrame_SetSelection", function()
		local tex = CraftIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end
	end)

	for i = 1, MAX_CRAFT_REAGENTS do
		local icon = _G["CraftReagent"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(icon)

		local nameFrame = _G["CraftReagent"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = F.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end
end

C.themes["Blizzard_TradeSkillUI"] = function()
	F.ReskinPortraitFrame(TradeSkillFrame, 10, -10, -30, 70)
	F.ReskinScroll(TradeSkillListScrollFrameScrollBar)
	F.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
	F.Reskin(TradeSkillCreateAllButton)
	F.Reskin(TradeSkillCreateButton)
	F.Reskin(TradeSkillCancelButton)
	F.ReskinArrow(TradeSkillDecrementButton, "left")
	F.ReskinArrow(TradeSkillIncrementButton, "right")
	F.ReskinInput(TradeSkillInputBox)

	F.StripTextures(TradeSkillRankFrameBorder)
	F.StripTextures(TradeSkillRankFrame)
	TradeSkillRankFrame:SetStatusBarColor(C.media.backdrop)
	F.CreateBDFrame(TradeSkillRankFrame, .25)
	TradeSkillRankFrame:SetWidth(220)

	F.ReskinExpandOrCollapse(TradeSkillCollapseAllButton)
	TradeSkillExpandButtonFrame:DisableDrawLayer("BACKGROUND")
	for i = 1, 8 do
		local bu = _G["TradeSkillSkill"..i]
		F.ReskinExpandOrCollapse(bu)
	end
	F.ReskinDropDown(TradeSkillSubClassDropDown)
	F.ReskinDropDown(TradeSkillInvSlotDropDown)

	F.StripTextures(TradeSkillDetailScrollChildFrame)
	F.StripTextures(TradeSkillSkillIcon)
	F.CreateBDFrame(TradeSkillSkillIcon)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		local tex = TradeSkillSkillIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality))
			else
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(icon)

		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = F.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end
end