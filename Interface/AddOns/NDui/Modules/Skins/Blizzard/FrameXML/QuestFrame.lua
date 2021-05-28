local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(QuestFrame, 15, -15, -30, 65)

	B.StripTextures(QuestFrameDetailPanel)
	B.StripTextures(QuestFrameRewardPanel)
	B.StripTextures(QuestFrameProgressPanel)
	B.StripTextures(QuestFrameGreetingPanel)
	B.StripTextures(EmptyQuestLogFrame)

	hooksecurefunc("QuestFrame_SetMaterial", function(frame)
		_G[frame:GetName().."MaterialTopLeft"]:Hide()
		_G[frame:GetName().."MaterialTopRight"]:Hide()
		_G[frame:GetName().."MaterialBotLeft"]:Hide()
		_G[frame:GetName().."MaterialBotRight"]:Hide()
	end)

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
		B.CreateBDFrame(bu, .25)
		na:Hide()
		co:SetDrawLayer("OVERLAY")
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
		B.Reskin(_G[questButton])
	end
	B.ReskinScroll(QuestProgressScrollFrameScrollBar)
	B.ReskinScroll(QuestRewardScrollFrameScrollBar)
	B.ReskinScroll(QuestDetailScrollFrameScrollBar)
	B.ReskinScroll(QuestGreetingScrollFrameScrollBar)

	-- Text colour stuff

	QuestProgressRequiredItemsText:SetTextColor(1, .8, 0)
	QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText:SetTextColor(1, .8, 0)
	QuestProgressTitleText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText.SetTextColor = B.Dummy
	QuestProgressText:SetTextColor(1, 1, 1)
	QuestProgressText.SetTextColor = B.Dummy
	GreetingText:SetTextColor(1, 1, 1)
	GreetingText.SetTextColor = B.Dummy
	AvailableQuestsText:SetTextColor(1, 1, 1)
	AvailableQuestsText.SetTextColor = B.Dummy
	AvailableQuestsText:SetShadowColor(0, 0, 0)
	CurrentQuestsText:SetTextColor(1, 1, 1)
	CurrentQuestsText.SetTextColor = B.Dummy
	CurrentQuestsText:SetShadowColor(0, 0, 0)

	-- [[ Quest NPC model ]]
	B.StripTextures(QuestNPCModel)
	B.SetBD(QuestNPCModel)
	B.StripTextures(QuestNPCModelTextFrame)
	B.SetBD(QuestNPCModelTextFrame)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, _, x, y)
		x = x + 5
		QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y)
	end)

	B.ReskinScroll(QuestNPCModelTextScrollFrameScrollBar)

	-- QuestLogFrame

	QuestLogQuestTitle:SetTextColor(1, .8, 0)
	QuestLogDescriptionTitle:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText.SetTextColor = B.Dummy
	QuestLogItemReceiveText:SetTextColor(1, 1, 1)
	QuestLogItemReceiveText.SetTextColor = B.Dummy
	QuestLogItemChooseText:SetTextColor(1, 1, 1)
	QuestLogItemChooseText.SetTextColor = B.Dummy
	QuestLogTimerText:SetTextColor(1, .8, 0)
	QuestLogTimerText.SetTextColor = B.Dummy
	for i = 1, 10 do
		local text = _G["QuestLogObjective"..i]
		text:SetTextColor(1, 1, 1)
		text.SetTextColor = B.Dummy
	end

	B.ReskinPortraitFrame(QuestLogFrame, 10, -10, -30, 45)
	B.Reskin(QuestLogFrameAbandonButton)
	B.Reskin(QuestFramePushQuestButton)
	B.Reskin(QuestFrameExitButton)
	B.ReskinScroll(QuestLogDetailScrollFrameScrollBar)
	B.ReskinScroll(QuestLogListScrollFrameScrollBar)
	B.StripTextures(QuestLogCount)
	B.CreateBDFrame(QuestLogCount, .25)

	B.ReskinCollapse(QuestLogCollapseAllButton)
	QuestLogCollapseAllButton:DisableDrawLayer("BACKGROUND")

	B.StripTextures(QuestLogTrack)
	QuestLogTrack:SetSize(8, 8)
	QuestLogTrackTitle:SetPoint("LEFT", QuestLogTrack, "RIGHT", 3, 0)
	QuestLogTrackTracking:SetTexture(DB.bdTex)
	B.CreateBDFrame(QuestLogTrackTracking)

	hooksecurefunc("QuestLog_Update", function()
		for i = 1, QUESTS_DISPLAYED, 1 do
			local bu = _G["QuestLogTitle"..i]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu.styled = true
			end
		end
	end)

	for i = 1, 10 do
		local icon = _G["QuestLogItem"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(icon)
		local nameFrame = _G["QuestLogItem"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = B.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end

	C_Timer.After(3, function()
		if CodexQuestShow then
			B.Reskin(CodexQuestShow)
			B.Reskin(CodexQuestHide)
			B.Reskin(CodexQuestReset)
		end
	end)

	-- QuestTimerFrame

	B.StripTextures(QuestTimerFrame)
	B.SetBD(QuestTimerFrame)
end)