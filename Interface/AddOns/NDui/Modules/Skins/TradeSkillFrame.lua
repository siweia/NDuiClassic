local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")

local skinIndex = 0
function S:TradeSkill_OnEvent(addon)
	if addon == "Blizzard_CraftUI" then
		S:EnhancedCraft()
		skinIndex = skinIndex + 1
	elseif addon == "Blizzard_TradeSkillUI" then
		S:EnhancedTradeSkill()
		skinIndex = skinIndex + 1
	end

	if skinIndex >= 2 then
		B:UnregisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
	end
end

function S:TradeSkillSkin()
	if not NDuiDB["Skins"]["TradeSkills"] then return end

	B:RegisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
end

-- LeatrixPlus
function S:EnhancedTradeSkill()
	if TradeSkillFrame:GetWidth() > 700 then return end

	-- Make the tradeskill frame double-wide
	UIPanelWindows["TradeSkillFrame"] = {area = "override", pushable = 1, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 714, height = 487, whileDead = 1}

	-- Size the tradeskill frame
	TradeSkillFrame:SetWidth(714)
	TradeSkillFrame:SetHeight(487)

	-- Adjust title text
	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame, "TOP", 0, -18)

	-- Expand the tradeskill list to full height
	TradeSkillListScrollFrame:ClearAllPoints()
	TradeSkillListScrollFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 25, -75)
	TradeSkillListScrollFrame:SetSize(295, 336)

	-- Create additional list rows
	local oldTradeSkillsDisplayed = TRADE_SKILLS_DISPLAYED

	-- Position existing buttons
	for i = 1 + 1, TRADE_SKILLS_DISPLAYED do
		_G["TradeSkillSkill"..i]:ClearAllPoints()
		_G["TradeSkillSkill"..i]:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i-1)], "BOTTOMLEFT", 0, 1)
	end

	-- Create and position new buttons
	_G.TRADE_SKILLS_DISPLAYED = _G.TRADE_SKILLS_DISPLAYED + 14
	for i = oldTradeSkillsDisplayed + 1, TRADE_SKILLS_DISPLAYED do
		local button = CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i-1)], "BOTTOMLEFT", 0, 1)
	end

	-- Set highlight bar width when shown
	hooksecurefunc(TradeSkillHighlightFrame, "Show", function(self)
		self:SetWidth(290)
	end)

	-- Move the tradeskill detail frame to the right and stretch it to full height
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 352, -74)
	TradeSkillDetailScrollFrame:SetSize(298, 336)
	-- TradeSkillReagent1:SetHeight(500) -- Debug

	-- Hide detail scroll frame textures
	TradeSkillDetailScrollFrameTop:SetAlpha(0)
	TradeSkillDetailScrollFrameBottom:SetAlpha(0)

	-- Create texture for skills list
	local RecipeInset = TradeSkillFrame:CreateTexture(nil, "ARTWORK")
	RecipeInset:SetSize(304, 361)
	RecipeInset:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 16, -72)
	RecipeInset:SetTexture("Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg")

	-- Set detail frame backdrop
	local DetailsInset = TradeSkillFrame:CreateTexture(nil, "ARTWORK")
	DetailsInset:SetSize(302, 339)
	DetailsInset:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 348, -72)
	DetailsInset:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated")

	-- Hide expand tab (left of All button)
	TradeSkillExpandTabLeft:Hide()

	-- Get tradeskill frame textures
	local regions = {TradeSkillFrame:GetRegions()}

	-- Set top left texture
	regions[2]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[2]:SetSize(512, 512)

	-- Set top right texture
	regions[3]:ClearAllPoints()
	regions[3]:SetPoint("TOPLEFT", regions[2], "TOPRIGHT", 0, 0)
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[3]:SetSize(256, 512)

	-- Hide bottom left and bottom right textures
	regions[4]:Hide()
	regions[5]:Hide()

	-- Hide skills list dividing bar
	regions[9]:Hide()
	regions[10]:Hide()

	-- Move create button row
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", -1, 0)

	-- Position and size close button
	TradeSkillCancelButton:SetSize(80, 22)
	TradeSkillCancelButton:SetText(CLOSE)
	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 54)

	-- Position close box
	TradeSkillFrameCloseButton:ClearAllPoints()
	TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -30, -8)

	-- Position dropdown menus
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:SetPoint("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 0, 0)

	-- AuroraClassic
	if F then
		regions[2]:Hide()
		regions[3]:Hide()
		RecipeInset:Hide()
		DetailsInset:Hide()
		TradeSkillFrame:SetHeight(512)
		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 78)
		TradeSkillRankFrame:ClearAllPoints()
		TradeSkillRankFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 24, -44)
	end
end

function S:EnhancedCraft()
	-- Make the craft frame double-wide
	UIPanelWindows["CraftFrame"] = {area = "override", pushable = 1, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 714, height = 487, whileDead = 1}

	-- Size the craft frame
	CraftFrame:SetWidth(714)
	CraftFrame:SetHeight(487)

	-- Adjust title text
	CraftFrameTitleText:ClearAllPoints()
	CraftFrameTitleText:SetPoint("TOP", CraftFrame, "TOP", 0, -18)

	-- Expand the crafting list to full height
	CraftListScrollFrame:ClearAllPoints()
	CraftListScrollFrame:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 25, -75)
	CraftListScrollFrame:SetSize(295, 336)

	-- Create additional list rows
	local oldCraftsDisplayed = CRAFTS_DISPLAYED

	-- Position existing buttons
	Craft1Cost:ClearAllPoints()
	Craft1Cost:SetPoint("RIGHT", Craft1, "RIGHT", -30, 0)
	for i = 1 + 1, CRAFTS_DISPLAYED do
		_G["Craft"..i]:ClearAllPoints()
		_G["Craft"..i]:SetPoint("TOPLEFT", _G["Craft"..(i-1)], "BOTTOMLEFT", 0, 1)
		_G["Craft"..i.."Cost"]:ClearAllPoints()
		_G["Craft"..i.."Cost"]:SetPoint("RIGHT", _G["Craft"..i], "RIGHT", -30, 0)
	end

	-- Create and position new buttons
	_G.CRAFTS_DISPLAYED = _G.CRAFTS_DISPLAYED + 14
	for i = oldCraftsDisplayed + 1, CRAFTS_DISPLAYED do
		local button = CreateFrame("Button", "Craft"..i, CraftFrame, "CraftButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["Craft"..(i-1)], "BOTTOMLEFT", 0, 1)
		_G["Craft"..i.."Cost"]:ClearAllPoints()
		_G["Craft"..i.."Cost"]:SetPoint("RIGHT", _G["Craft"..i], "RIGHT", -30, 0)
	end

	-- Move craft frame points (such as Beast Training)
	CraftFramePointsLabel:ClearAllPoints()
	CraftFramePointsLabel:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 100, -50)
	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:SetPoint("LEFT", CraftFramePointsLabel, "RIGHT", 3, 0)

	-- Set highlight bar width when shown
	hooksecurefunc(CraftHighlightFrame, "Show", function(self)
		self:SetWidth(290)
	end)

	-- Move the craft detail frame to the right and stretch it to full height
	CraftDetailScrollFrame:ClearAllPoints()
	CraftDetailScrollFrame:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 352, -74)
	CraftDetailScrollFrame:SetSize(298, 336)
	-- CraftReagent1:SetHeight(500) -- Debug

	-- Hide detail scroll frame textures
	CraftDetailScrollFrameTop:SetAlpha(0)
	CraftDetailScrollFrameBottom:SetAlpha(0)

	-- Create texture for skills list
	local RecipeInset = CraftFrame:CreateTexture(nil, "ARTWORK")
	RecipeInset:SetSize(304, 361)
	RecipeInset:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 16, -72)
	RecipeInset:SetTexture("Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg")

	-- Set detail frame backdrop
	local DetailsInset = CraftFrame:CreateTexture(nil, "ARTWORK")
	DetailsInset:SetSize(302, 339)
	DetailsInset:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 348, -72)
	DetailsInset:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated")

	-- Hide expand tab (left of All button)
	CraftExpandTabLeft:Hide()

	-- Get craft frame textures
	local regions = {CraftFrame:GetRegions()}

	-- Set top left texture
	regions[2]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[2]:SetSize(512, 512)

	-- Set top right texture
	regions[3]:ClearAllPoints()
	regions[3]:SetPoint("TOPLEFT", regions[2], "TOPRIGHT", 0, 0)
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[3]:SetSize(256, 512)

	-- Hide bottom left and bottom right textures
	regions[4]:Hide()
	regions[5]:Hide()

	-- Hide skills list dividing bar
	regions[9]:Hide()
	regions[10]:Hide()

	-- Move create button row
	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:SetPoint("RIGHT", CraftCancelButton, "LEFT", -1, 0)

	-- Position and size close button
	CraftCancelButton:SetSize(80, 22)
	CraftCancelButton:SetText(CLOSE)
	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 54)

	-- Position close box
	CraftFrameCloseButton:ClearAllPoints()
	CraftFrameCloseButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -30, -8)

	if F then
		regions[2]:Hide()
		regions[3]:Hide()
		RecipeInset:Hide()
		DetailsInset:Hide()
		CraftFrame:SetHeight(512)
		CraftCancelButton:ClearAllPoints()
		CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 78)
		CraftRankFrame:ClearAllPoints()
		CraftRankFrame:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 24, -44)
	end
end