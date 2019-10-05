local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(QuestFrame, 15, -15, -30, 65)

	F.StripTextures(QuestFrameDetailPanel)
	F.StripTextures(QuestFrameRewardPanel)
	F.StripTextures(QuestFrameProgressPanel)
	F.StripTextures(QuestFrameGreetingPanel)
	F.StripTextures(EmptyQuestLogFrame)

	local line = QuestFrameGreetingPanel:CreateTexture()
	line:SetColorTexture(1, 1, 1, .25)
	line:SetSize(256, C.mult)
	line:SetPoint("CENTER", QuestGreetingFrameHorizontalBreak)
	QuestGreetingFrameHorizontalBreak:SetTexture("")
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		line:SetShown(QuestGreetingFrameHorizontalBreak:IsShown())
	end)

	for i = 1, MAX_REQUIRED_ITEMS do
		local bu = _G["QuestProgressItem"..i]
		local ic = _G["QuestProgressItem"..i.."IconTexture"]
		local na = _G["QuestProgressItem"..i.."NameFrame"]
		local co = _G["QuestProgressItem"..i.."Count"]
		ic:SetSize(40, 40)
		ic:SetTexCoord(.08, .92, .08, .92)
		ic:SetDrawLayer("OVERLAY")
		F.CreateBD(bu, .25)
		na:Hide()
		co:SetDrawLayer("OVERLAY")

		local line = CreateFrame("Frame", nil, bu)
		line:SetSize(1, 40)
		line:SetPoint("RIGHT", ic, 1, 0)
		F.CreateBD(line)
	end

	QuestDetailScrollFrame:SetWidth(302) -- else these buttons get cut off

	hooksecurefunc(QuestProgressRequiredMoneyText, "SetTextColor", function(self, r)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	local buttons = {
		"QuestFrameAcceptButton",
		"QuestFrameDeclineButton",
		"QuestFrameCompleteQuestButton",
		"QuestFrameCompleteButton",
		"QuestFrameGoodbyeButton",
		"QuestFrameGreetingGoodbyeButton",
		"QuestFrameCancelButton"
	}
	for _, questButton in next, buttons do
		F.Reskin(_G[questButton])
	end
	F.ReskinScroll(QuestProgressScrollFrameScrollBar)
	F.ReskinScroll(QuestRewardScrollFrameScrollBar)
	F.ReskinScroll(QuestDetailScrollFrameScrollBar)
	F.ReskinScroll(QuestGreetingScrollFrameScrollBar)

	-- Text colour stuff

	QuestProgressRequiredItemsText:SetTextColor(1, .8, 0)
	QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText:SetTextColor(1, .8, 0)
	QuestProgressTitleText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText.SetTextColor = F.dummy
	QuestProgressText:SetTextColor(1, 1, 1)
	QuestProgressText.SetTextColor = F.dummy
	GreetingText:SetTextColor(1, 1, 1)
	GreetingText.SetTextColor = F.dummy
	AvailableQuestsText:SetTextColor(1, 1, 1)
	AvailableQuestsText.SetTextColor = F.dummy
	AvailableQuestsText:SetShadowColor(0, 0, 0)
	CurrentQuestsText:SetTextColor(1, 1, 1)
	CurrentQuestsText.SetTextColor = F.dummy
	CurrentQuestsText:SetShadowColor(0, 0, 0)

	-- [[ Quest NPC model ]]
	F.StripTextures(QuestNPCModel)
	F.StripTextures(QuestNPCModelTextFrame)

	local npcbd = CreateFrame("Frame", nil, QuestNPCModel)
	npcbd:SetPoint("TOPLEFT", -1, 1)
	npcbd:SetPoint("RIGHT", 2, 0)
	npcbd:SetPoint("BOTTOM", QuestNPCModelTextScrollFrame)
	npcbd:SetFrameLevel(0)
	F.CreateBD(npcbd)
	F.CreateSD(npcbd)

	local npcLine = CreateFrame("Frame", nil, QuestNPCModel)
	npcLine:SetPoint("BOTTOMLEFT", 0, -1)
	npcLine:SetPoint("BOTTOMRIGHT", 1, -1)
	npcLine:SetHeight(C.mult)
	npcLine:SetFrameLevel(0)
	F.CreateBD(npcLine, 0)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, _, x, y)
		x = x + 5
		QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y)
	end)

	F.ReskinScroll(QuestNPCModelTextScrollFrameScrollBar)

	-- QuestLogFrame

	QuestLogQuestTitle:SetTextColor(1, .8, 0)
	QuestLogDescriptionTitle:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText.SetTextColor = F.dummy
	QuestLogItemReceiveText:SetTextColor(1, 1, 1)
	QuestLogItemReceiveText.SetTextColor = F.dummy
	QuestLogItemChooseText:SetTextColor(1, 1, 1)
	QuestLogItemChooseText.SetTextColor = F.dummy
	for i = 1, 10 do
		local text = _G["QuestLogObjective"..i]
		text:SetTextColor(1, 1, 1)
		text.SetTextColor = F.dummy
	end

	F.ReskinPortraitFrame(QuestLogFrame, 10, -10, -30, 45)
	F.Reskin(QuestLogFrameAbandonButton)
	F.Reskin(QuestFramePushQuestButton)
	F.Reskin(QuestFrameExitButton)
	F.ReskinScroll(QuestLogDetailScrollFrameScrollBar)
	F.ReskinScroll(QuestLogListScrollFrameScrollBar)

	F.ReskinExpandOrCollapse(QuestLogCollapseAllButton)
	QuestLogCollapseAllButton:DisableDrawLayer("BACKGROUND")

	F.StripTextures(QuestLogTrack)
	QuestLogTrack:SetSize(8, 8)
	QuestLogTrackTitle:SetPoint("LEFT", QuestLogTrack, "RIGHT", 3, 0)
	QuestLogTrackTracking:SetTexture(C.media.backdrop)
	F.CreateBDFrame(QuestLogTrackTracking)

	hooksecurefunc("QuestLog_Update", function()
		for i = 1, QUESTS_DISPLAYED, 1 do
			local bu = _G["QuestLogTitle"..i]
			if bu.isHeader and not bu.styled then
				F.ReskinExpandOrCollapse(bu)
				bu.styled = true
			end
		end
	end)

	for i = 1, 10 do
		local icon = _G["QuestLogItem"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(icon)
		local nameFrame = _G["QuestLogItem"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = F.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end

	C_Timer.After(3, function()
		if CodexQuestShow then
			F.Reskin(CodexQuestShow)
			F.Reskin(CodexQuestHide)
			F.Reskin(CodexQuestReset)
		end
	end)

	-- QuestTimerFrame

	F.StripTextures(QuestTimerFrame)
	F.CreateSD(F.CreateBDFrame(QuestTimerFrame))
end)