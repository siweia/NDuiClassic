local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

-- Credit: LeatrixPlus
local strfind = strfind
local GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills = GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills
local GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts = GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts

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
	if not C.db["Skins"]["TradeSkills"] then return end

	B:RegisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
end

local function createArrowButton(parent, anchor, direction)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
	B.ReskinArrow(button, direction)
	if C.db["Skins"]["BlizzardSkins"] then
		button:SetSize(20, 20)
	end

	return button
end

local function removeInputText(self)
	self:SetText("")
end

function S:CreateSearchWidget(parent, anchor)
	local title = B.CreateFS(parent, 15, SEARCH, "system")
	title:ClearAllPoints()

	local searchBox = B.CreateEditBox(parent, 150, 20)
	if C.db["Skins"]["BlizzardSkins"] then
		title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 6, -6)
		searchBox.bg:SetBackdropColor(0, 0, 0, 0)
		searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 3, 3)
		searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, -23)
	else
		title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 5, -5)
		searchBox:SetFrameLevel(6)
		searchBox.bg:SetBackdropColor(0, 0, 0)
		searchBox.bg:SetBackdropBorderColor(1, .8, 0, .5)
		searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 3, 1)
		searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -42, -20)
	end
	searchBox:HookScript("OnEscapePressed", removeInputText)
	searchBox.title = L["Tips"]
	B.AddTooltip(searchBox, "ANCHOR_TOP", L["TradeSearchTip"]..L["EditBox Tip"], "info")

	local nextButton = createArrowButton(searchBox, searchBox, "down")
	local prevButton = createArrowButton(searchBox, nextButton, "up")

	return searchBox, nextButton, prevButton
end

local function updateScrollBarValue(scrollBar, maxSkills, selectSkill)
	local _, maxValue = scrollBar:GetMinMaxValues()
	if maxValue == 0 then return end
	local maxIndex = maxSkills - 22
	if maxIndex <= 0 then return end
	local selectIndex = selectSkill - 22
	if selectIndex < 0 then selectIndex = 0 end

	scrollBar:SetValue(selectIndex / maxIndex * maxValue)
end

function S:UpdateTradeSelection(i, maxSkills)
	TradeSkillFrame_SetSelection(i)
	TradeSkillFrame_Update()
	updateScrollBarValue(TradeSkillListScrollFrameScrollBar, maxSkills, GetTradeSkillSelectionIndex())
end

function S:GetTradeSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetTradeSkillInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			S:UpdateTradeSelection(i, GetNumTradeSkills())
			return true
		end
	end
end

function S:UpdateCraftSelection(i, maxSkills)
	CraftFrame_SetSelection(i)
	CraftFrame_Update()
	updateScrollBarValue(CraftListScrollFrameScrollBar, maxSkills, GetCraftSelectionIndex())
end

function S:GetCraftSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetCraftInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			S:UpdateCraftSelection(i, GetNumCrafts())
			return true
		end
	end
end

local SharedWindowData = {
	area = "override",
	pushable = 1,
	xoffset = -16,
	yoffset = 12,
	bottomClampOverride = 140 + 12,
	width = 714,
	height = 487,
	whileDead = 1,
}

local function ResizeHighlightFrame(self)
	self:SetWidth(290)
end

function S:EnhancedTradeSkill()
	if TradeSkillFrame:GetWidth() > 700 then return end

	-- Make the tradeskill frame double-wide
	UIPanelWindows["TradeSkillFrame"] = SharedWindowData

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
	hooksecurefunc(TradeSkillHighlightFrame, "Show", ResizeHighlightFrame)

	-- Move the tradeskill detail frame to the right and stretch it to full height
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 352, -74)
	TradeSkillDetailScrollFrame:SetSize(298, 336)

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
	TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -34, -13)

	-- Position dropdown menus
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:SetPoint("RIGHT", TradeSkillInvSlotDropDown, "LEFT", 0, 0)

	-- Reskin
	if C.db["Skins"]["BlizzardSkins"] then
		regions[2]:Hide()
		regions[3]:Hide()
		RecipeInset:Hide()
		DetailsInset:Hide()
		TradeSkillFrame:SetHeight(512)
		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 78)
		TradeSkillRankFrame:ClearAllPoints()
		TradeSkillRankFrame:SetPoint("TOPLEFT", TradeSkillFrame, 24, -24)
	end

	-- Search widgets
	local searchBox, nextButton, prevButton = S:CreateSearchWidget(TradeSkillFrame, TradeSkillRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() + 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)
end

function S:EnhancedCraft()
	-- Make the craft frame double-wide
	UIPanelWindows["CraftFrame"] = SharedWindowData

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
	CraftFramePointsLabel:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 100, -70)
	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:SetPoint("LEFT", CraftFramePointsLabel, "RIGHT", 3, 0)

	-- Set highlight bar width when shown
	hooksecurefunc(CraftHighlightFrame, "Show", ResizeHighlightFrame)

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
	CraftFrameCloseButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -34, -13)
	--CraftFrameFilterDropDown:ClearAllPoints()
	--CraftFrameFilterDropDown:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 510, -40)
	--CraftFrameAvailableFilterCheckButton:ClearAllPoints()
	--CraftFrameAvailableFilterCheckButton:SetPoint("RIGHT", CraftFrameFilterDropDown, "LEFT", -130, 2)

	-- Reskin
	if C.db["Skins"]["BlizzardSkins"] then
		regions[2]:Hide()
		regions[3]:Hide()
		RecipeInset:Hide()
		DetailsInset:Hide()
		CraftFrame:SetHeight(512)
		CraftCancelButton:ClearAllPoints()
		CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 78)
		CraftRankFrame:ClearAllPoints()
		CraftRankFrame:SetPoint("TOPLEFT", CraftFrame, 24, -24)
	end

	local searchBox, nextButton, prevButton = S:CreateSearchWidget(CraftFrame, CraftRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, GetCraftSelectionIndex()+1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, GetCraftSelectionIndex()-1, 1, -1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)
end