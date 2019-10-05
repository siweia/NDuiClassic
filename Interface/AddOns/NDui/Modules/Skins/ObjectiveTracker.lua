local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")

local _G = getfenv(0)
local pairs, tinsert, select = pairs, tinsert, select
local GetNumQuestLogEntries, GetQuestLogTitle, GetNumQuestWatches = GetNumQuestLogEntries, GetQuestLogTitle, GetNumQuestWatches
local IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool = IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool
local GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard = GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

local cr, cg, cb = DB.r, DB.g, DB.b
local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY or 2
local MAX_QUESTLOG_QUESTS = MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = MAX_WATCHABLE_QUESTS or 5
local headerString = QUESTS_LABEL.." %s/%s"

local frame

function S:EnhancedQuestLog()
	if QuestLogFrame:GetWidth() > 700 then return end

	-- LeatrixPlus EnhancedQuestLog
	-- Make the quest log frame double-wide
	UIPanelWindows["QuestLogFrame"] = { area = "override", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 714, height = 487, whileDead = 1}

	-- Size the quest log frame
	QuestLogFrame:SetWidth(714)
	QuestLogFrame:SetHeight(487)

	-- Adjust quest log title text
	QuestLogTitleText:ClearAllPoints()
	QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18)

	-- Move the detail frame to the right and stretch it to full height
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 31, 1)
	QuestLogDetailScrollFrame:SetHeight(336)

	-- Expand the quest list to full height
	QuestLogListScrollFrame:SetHeight(336)

	-- Create additional quest rows
	local oldQuestsDisplayed = QUESTS_DISPLAYED
	_G.QUESTS_DISPLAYED = _G.QUESTS_DISPLAYED + 16
	for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
		local button = CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["QuestLogTitle"..(i-1)], "BOTTOMLEFT", 0, 1)
	end

	if not F then
		-- Get quest frame textures
		local regions = {QuestLogFrame:GetRegions()}
		-- Set top left texture
		regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
		regions[3]:SetSize(512, 512)
		-- Set top right texture
		regions[4]:ClearAllPoints()
		regions[4]:SetPoint("TOPLEFT", regions[3], "TOPRIGHT", 0, 0)
		regions[4]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
		regions[4]:SetSize(256, 512)
		-- Hide bottom left and bottom right textures
		regions[5]:Hide()
		regions[6]:Hide()
	end

	-- Position and resize abandon button
	QuestLogFrameAbandonButton:SetSize(100, 22)
	QuestLogFrameAbandonButton:SetText(ABANDON_QUEST_ABBREV)
	QuestLogFrameAbandonButton:ClearAllPoints()
	QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 17, 52)

	-- Position and resize share button
	QuestFramePushQuestButton:SetSize(100, 22)
	QuestFramePushQuestButton:SetText(SHARE_QUEST_ABBREV)
	QuestFramePushQuestButton:ClearAllPoints()
	QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 3, 0)

	-- Add map button
	local logMapButton = CreateFrame("Button", nil, QuestLogFrame, "UIPanelButtonTemplate")
	logMapButton:SetText(BRAWL_TOOLTIP_MAP)
	logMapButton:ClearAllPoints()
	logMapButton:SetPoint("LEFT", QuestFramePushQuestButton, "RIGHT", 3, 0)
	logMapButton:SetSize(100, 22)
	logMapButton:SetScript("OnClick", ToggleWorldMap)
	if F then F.Reskin(logMapButton) end

	-- Position and size close button
	QuestFrameExitButton:SetSize(80, 22)
	QuestFrameExitButton:SetText(CLOSE)
	QuestFrameExitButton:ClearAllPoints()
	QuestFrameExitButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -42, 52)

	-- Empty quest frame
	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -50)
	hooksecurefunc(EmptyQuestLogFrame, "Show", function()
		EmptyQuestLogFrame:ClearAllPoints()
		EmptyQuestLogFrame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 20, -76)
		EmptyQuestLogFrame:SetHeight(487)
	end)

	-- Move ClassicCodex
	if CodexQuest then
		local buttonShow = CodexQuest.buttonShow
		buttonShow:SetWidth(55)
		buttonShow:SetText(DB.InfoColor..SHOW)

		local buttonHide = CodexQuest.buttonHide
		buttonHide:ClearAllPoints()
		buttonHide:SetPoint("LEFT", buttonShow, "RIGHT", 5, 0)
		buttonHide:SetWidth(55)
		buttonHide:SetText(DB.InfoColor..HIDE)

		local buttonReset = CodexQuest.buttonReset
		buttonReset:ClearAllPoints()
		buttonReset:SetPoint("LEFT", buttonHide, "RIGHT", 5, 0)
		buttonReset:SetWidth(55)
		buttonReset:SetText(DB.InfoColor..RESET)
	end
end

function S:QuestLogLevel()
	local numEntries = GetNumQuestLogEntries()

	for i = 1, QUESTS_DISPLAYED, 1 do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
		local questLogTitle = _G["QuestLogTitle"..i]
		local questCheck = _G["QuestLogTitle"..i.."Check"]
		local questTitleTag = _G["QuestLogTitle"..i.."Tag"]
		if questIndex <= numEntries then
			local questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("["..level.."] "..questLogTitleText)
				questCheck:SetPoint("LEFT", questLogTitle, questLogTitle:GetWidth()-22, 0)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = .5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, .5, 1)
				end
			end
		end
	end
end

function S:EnhancedQuestTracker()
	local header = CreateFrame("Frame", nil, frame)
	header:SetAllPoints()
	header:SetParent(QuestWatchFrame)
	header.Text = B.CreateFS(header, 16, "", true, "TOPLEFT", 0, 15)

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(cr, cg, cb, .8)
	bg:SetPoint("TOPLEFT", 0, 20)
	bg:SetSize(250, 30)

	local bu = CreateFrame("Button", nil, frame)
	bu:SetSize(20, 20)
	bu:SetPoint("TOPRIGHT", 0, 18)
	bu.collapse = false
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	if F then
		bu:SetPoint("TOPRIGHT", 0, 14)
		F.ReskinExpandOrCollapse(bu)
		bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	end
	bu:SetShown(GetNumQuestWatches() > 0)

	bu.Text = B.CreateFS(bu, 16, TRACKER_HEADER_OBJECTIVE, "system", "RIGHT", -24, F and 3 or 0)
	bu.Text:Hide()

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		if self.collapse then
			self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			self.Text:Show()
			QuestWatchFrame:Hide()
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
			self.Text:Hide()
			if GetNumQuestWatches() > 0 then
				QuestWatchFrame:Show()
			end
		end
	end)

	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if IsShiftKeyDown() then -- untrack quest
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					tremove(QUEST_WATCH_LIST, index)
				end
			end
			RemoveQuestWatch(self.questIndex)
			QuestWatch_Update()
		else -- open to quest log
			if QuestLogEx then -- https://www.wowinterface.com/downloads/info24980-QuestLogEx.html
				ShowUIPanel(QuestLogExFrame)
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then -- https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html
				ShowUIPanel(ClassicQuestLog)
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then -- https://www.curseforge.com/wow/addons/questguru_classic
				ShowUIPanel(QuestGuru)
				QuestLog_SetSelection(self.questIndex)
			else
				ShowUIPanel(QuestLogFrame)
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue(self.questIndex*valueStep/2)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		if self.completed then
			-- use normal colors instead as highlight
			self.headerText:SetTextColor(.75, .61, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(.8, .8, .8)
			end
		else
			self.headerText:SetTextColor(1, .8, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local ClickFrames = {}
	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		if not ClickFrames[watchIndex] then
			ClickFrames[watchIndex] = CreateFrame("Frame")
			ClickFrames[watchIndex]:SetScript("OnMouseUp", onMouseUp)
			ClickFrames[watchIndex]:SetScript("OnEnter", onEnter)
			ClickFrames[watchIndex]:SetScript("OnLeave", QuestWatch_Update)
		end

		local f = ClickFrames[watchIndex]
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
	end

	hooksecurefunc("QuestWatch_Update", function()
		local numQuests = select(2, GetNumQuestLogEntries())
		header.Text:SetFormattedText(headerString, numQuests, MAX_QUESTLOG_QUESTS)

		local watchTextIndex = 1
		local numWatches = GetNumQuestWatches()
		for i = 1, numWatches do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local numObjectives = GetNumQuestLeaderBoards(questIndex)
				if numObjectives > 0 then
					local headerText = _G["QuestWatchLine"..watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						_G["QuestWatchLine"..watchTextIndex]:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						tinsert(objectivesGroup, _G["QuestWatchLine"..watchTextIndex])
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end
		-- hide/show frames so it doesnt eat clicks, since we cant parent to a FontString
		for _, frame in pairs(ClickFrames) do
			frame[GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide"](frame)
		end

		bu:SetShown(numWatches > 0)
		if bu.collapse then QuestWatchFrame:Hide() end
	end)

	local function autoQuestWatch(_, questIndex)
		-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
		-- calling AddQuestWatch() while on the max watch limit silently fails
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
		end
	end
	B:RegisterEvent("QUEST_ACCEPTED", autoQuestWatch)
end

function S:QuestTracker()
	-- Mover for quest tracker
	frame = CreateFrame("Frame", "NDuiQuestMover", UIParent)
	frame:SetSize(240, 50)
	B.Mover(frame, L["QuestTracker"], "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -70, -55})

	--QuestWatchFrame:SetHeight(GetScreenHeight()*.65)
	QuestWatchFrame:SetClampedToScreen(false)
	QuestWatchFrame:SetMovable(true)
	QuestWatchFrame:SetUserPlaced(true)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame, 5, -5)
		end
	end)

	local timerMover = CreateFrame("Frame", "NDuiQuestTimerMover", UIParent)
	timerMover:SetSize(150, 30)
	B.Mover(timerMover, QUEST_TIMERS, "QuestTimer", {"TOPRIGHT", frame, "TOPLEFT", -10, 0})

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(self, _, parent)
		if parent ~= timerMover then
			self:ClearAllPoints()
			self:SetPoint("TOP", timerMover)
		end
	end)

	if not NDuiDB["Skins"]["QuestTracker"] then return end

	S:EnhancedQuestLog()
	S:EnhancedQuestTracker()
	hooksecurefunc("QuestLog_Update", S.QuestLogLevel)
end