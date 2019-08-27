local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local pairs = pairs
local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY or 2

function S:QuestTracker()
	-- Mover for quest tracker
	local frame = CreateFrame("Frame", "NDuiQuestMover", UIParent)
	frame:SetSize(240, 50)
	B.Mover(frame, L["QuestTracker"], "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -70, -55})

	local tracker = QuestWatchFrame
	tracker:SetHeight(GetScreenHeight()*.65)
	tracker:SetClampedToScreen(false)
	tracker:SetMovable(true)
	if tracker:IsMovable() then tracker:SetUserPlaced(true) end

	hooksecurefunc(tracker, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)

	-- Show quest color and level
	local function Showlevel(self)
		local numEntries = GetNumQuestLogEntries()

		for i = 1, QUESTS_DISPLAYED, 1 do
			local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
			local questLogTitle = _G["QuestLogTitle"..i]
			local questCheck = _G["QuestLogTitle"..i.."Check"]

			if questIndex <= numEntries then
				local questLogTitleText, level, _, isHeader, _, isComplete, frequency = GetQuestLogTitle(questIndex)

				if not isHeader then
					questLogTitleText = "["..level.."] "..questLogTitleText
					if isComplete then
						questLogTitleText = "|cffff78ff"..questLogTitleText
					elseif frequency == LE_QUEST_FREQUENCY_DAILY then
						questLogTitleText = "|cff3399ff"..questLogTitleText
					end

					questLogTitle:SetText(questLogTitleText)
					questCheck:SetPoint("LEFT", questLogTitle, questLogTitle:GetWidth()-22, 0)
				end
			end
		end
	end
	hooksecurefunc("QuestLog_Update", Showlevel)
end