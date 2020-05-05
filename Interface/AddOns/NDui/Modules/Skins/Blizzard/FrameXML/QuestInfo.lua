local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local r, g, b = DB.r, DB.g, DB.b

	-- Item reward highlight
	local function clearHighlight()
		for _, button in pairs(QuestInfoRewardsFrame.RewardButtons) do
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end

	local function setHighlight(self)
		clearHighlight()

		local _, point = self:GetPoint()
		if point then
			point.bg:SetBackdropColor(r, g, b, .2)
		end
	end

	QuestInfoItemHighlight:GetRegions():Hide()
	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", setHighlight)
	QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

	-- Quest objective text color
	local function colourObjectivesText()
		if not QuestInfoFrame.questLog then return end

		local objectivesTable = QuestInfoObjectivesFrame.Objectives
		local numVisibleObjectives = 0

		for i = 1, GetNumQuestLeaderBoards() do
			local _, type, finished = GetQuestLogLeaderBoard(i)

			if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = objectivesTable[numVisibleObjectives]

				if objective then
					if finished then
						objective:SetTextColor(.9, .9, .9)
					else
						objective:SetTextColor(1, 1, 1)
					end
				end
			end
		end
	end

	-- Reskin rewards
	local function restyleSpellButton(bu)
		local name = bu:GetName()
		local icon = bu.Icon

		_G[name.."NameFrame"]:Hide()
		_G[name.."SpellBorder"]:Hide()

		icon:SetPoint("TOPLEFT", 3, -2)
		B.ReskinIcon(icon)

		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 2, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 14)
	end
	restyleSpellButton(QuestInfoSpellObjectiveFrame)

	local function restyleRewardButton(bu, isMapQuestInfo)
		bu.NameFrame:Hide()
		if bu.IconBorder then bu.IconBorder:SetAlpha(0) end

		if isMapQuestInfo then
			bu.Icon:SetSize(29, 29)
		else
			bu.Icon:SetSize(34, 34)
		end

		bu.iconBG = B.ReskinIcon(bu.Icon)

		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", iconBG, "TOPRIGHT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", iconBG, 100, 0)
		bu.bg = bg
	end

	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local bu = rewardsFrame.RewardButtons[index]
		if not bu.restyled then
			restyleRewardButton(bu, rewardsFrame == MapQuestInfoRewardsFrame)
			bu.restyled = true
		end
	end)

	MapQuestInfoRewardsFrame.XPFrame.Name:SetShadowOffset(0, 0)
	for _, name in next, {"HonorFrame", "MoneyFrame", "SkillPointFrame", "XPFrame", "ArtifactXPFrame", "TitleFrame"} do
		restyleRewardButton(MapQuestInfoRewardsFrame[name], true)
	end

	for _, name in next, {"HonorFrame", "SkillPointFrame", "ArtifactXPFrame"} do
		restyleRewardButton(QuestInfoRewardsFrame[name])
	end

	-- Title Reward
	do
		local frame = QuestInfoPlayerTitleFrame
		local icon = frame.Icon

		icon:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(icon)
		for i = 2, 4 do
			select(i, frame:GetRegions()):Hide()
		end
		local bg = B.CreateBDFrame(frame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 2)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 220, -1)
	end

	-- Others
	hooksecurefunc("QuestInfo_Display", function()
		colourObjectivesText()

        local rewardsFrame = QuestInfoFrame.rewardsFrame
        local isQuestLog = QuestInfoFrame.questLog ~= nil
		local numSpellRewards = isQuestLog and GetNumQuestLogRewardSpells() or GetNumRewardSpells()

		if numSpellRewards > 0 then
			-- Spell Headers
			for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
				spellHeader:SetVertexColor(1, 1, 1)
			end
			-- Spell Rewards
			for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
				if not spellReward.styled then
					local icon = spellReward.Icon
					local nameFrame = spellReward.NameFrame
					icon:SetTexCoord(.08, .92, .08, .92)
					B.CreateBDFrame(icon)
					nameFrame:Hide()
					local bg = B.CreateBDFrame(nameFrame, .25)
					bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 2)
					bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 101, -1)

					spellReward.styled = true
				end
			end
		end
	end)

	-- Change text colors
	QuestFont:SetTextColor(1, 1, 1)

	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", function(self, r)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	local function HookTextColor_Yellow(self)
		if self.isSetting then return end
		self.isSetting = true
		self:SetTextColor(1, .8, 0)
		self.isSetting = nil
	end

	local function SetTextColor_Yellow(font)
		font:SetShadowColor(0, 0, 0)
		font:SetTextColor(1, .8, 0)
		hooksecurefunc(font, "SetTextColor", HookTextColor_Yellow)
	end

	local yellowish = {
		QuestInfoTitleHeader,
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader,
		QuestInfoRewardsFrame.Header,
	}
	for _, font in pairs(yellowish) do
		SetTextColor_Yellow(font)
	end

	local function HookTextColor_White(self)
		if self.isSetting then return end
		self.isSetting = true
		self:SetTextColor(1, 1, 1)
		self.isSetting = nil
	end

	local function SetTextColor_White(font)
		font:SetShadowColor(0, 0, 0)
		font:SetTextColor(1, 1, 1)
		hooksecurefunc(font, "SetTextColor", HookTextColor_White)
	end

	local whitish = {
		QuestInfoDescriptionText,
		QuestInfoObjectivesText,
		QuestInfoGroupSize,
		QuestInfoRewardText,
		QuestInfoSpellObjectiveLearnLabel,
		QuestInfoRewardsFrame.ItemChooseText,
		QuestInfoRewardsFrame.ItemReceiveText,
		QuestInfoRewardsFrame.PlayerTitleText,
		QuestInfoRewardsFrame.XPFrame.ReceiveText,
	}
	for _, font in pairs(whitish) do
		SetTextColor_White(font)
	end
end)