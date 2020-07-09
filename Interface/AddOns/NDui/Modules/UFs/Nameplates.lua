local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local _G = getfenv(0)
local strmatch, tonumber, pairs, unpack, rad = string.match, tonumber, pairs, unpack, math.rad
local UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit = UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit
local UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor = UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor
local UnitClassification, UnitExists, InCombatLockdown = UnitClassification, UnitExists, InCombatLockdown
local UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName = UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName
local SetCVar, UIFrameFadeIn, UIFrameFadeOut = SetCVar, UIFrameFadeIn, UIFrameFadeOut
local INTERRUPTED = INTERRUPTED

-- Init
function UF:UpdatePlateScale()
	SetCVar("namePlateMinScale", NDuiDB["Nameplate"]["MinScale"])
	SetCVar("namePlateMaxScale", NDuiDB["Nameplate"]["MinScale"])
end

function UF:UpdatePlateAlpha()
	SetCVar("nameplateMinAlpha", GetCVarDefault("nameplateMinAlpha"))
	SetCVar("nameplateMaxAlpha", GetCVarDefault("nameplateMaxAlpha"))
end

function UF:UpdatePlateRange()
	SetCVar("nameplateMaxDistance", GetCVarDefault("nameplateMaxDistance"))
end

function UF:UpdatePlateSpacing()
	SetCVar("nameplateOverlapV", NDuiDB["Nameplate"]["VerticalSpacing"])
end

function UF:SetupCVars()
	SetCVar("nameplateOverlapH", .8)
	UF:UpdatePlateSpacing()
	UF:UpdatePlateRange()
	UF:UpdatePlateAlpha()
	SetCVar("nameplateSelectedAlpha", 1)

	UF:UpdatePlateScale()
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
end

function UF:BlockAddons()
	if not DBM or not DBM.Nameplate then return end

	function DBM.Nameplate:SupportedNPMod()
		return true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then return end
		if not C.WhiteList[spellID] then
			C.WhiteList[spellID] = true
		end
	end
	hooksecurefunc(DBM.Nameplate, "Show", showAurasForDBM)
end

-- Elements
local customUnits = {}
function UF:CreateUnitTable()
	wipe(customUnits)
	if not NDuiDB["Nameplate"]["CustomUnitColor"] then return end
	B.CopyTable(C.CustomUnits, customUnits)
	B.SplitList(customUnits, NDuiDB["Nameplate"]["UnitList"])
end

local showPowerList = {}
function UF:CreatePowerUnitTable()
	wipe(showPowerList)
	B.CopyTable(C.ShowPowerList, showPowerList)
	B.SplitList(showPowerList, NDuiDB["Nameplate"]["ShowPowerList"])
end

function UF:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

-- Update unit color
function UF.UpdateColor(self, _, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = customUnits[name] or customUnits[npcID]
	local isPlayer = UnitIsPlayer(unit)
	local status = UnitThreatSituation("player", unit) or false -- just in case
	local isTargeting = UnitIsUnit(unit.."target", "player")
	local reaction = UnitReaction(unit, "player")
	local customColor = NDuiDB["Nameplate"]["CustomColor"]
	local secureColor = NDuiDB["Nameplate"]["SecureColor"]
	local transColor = NDuiDB["Nameplate"]["TransColor"]
	local insecureColor = NDuiDB["Nameplate"]["InsecureColor"]
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if isCustomUnit then
			r, g, b = customColor.r, customColor.g, customColor.b
		elseif isPlayer and (reaction and reaction >= 5) then
			if NDuiDB["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif isPlayer and (reaction and reaction <= 4) and NDuiDB["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = UnitSelectionColor(unit, true)
			if status and NDuiDB["Nameplate"]["TankMode"] then
				if status == 3 then
					r, g, b = secureColor.r, secureColor.g, secureColor.b
				elseif status == 2 or status == 1 then
					r, g, b = transColor.r, transColor.g, transColor.b
				elseif status == 0 then
					r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if isCustomUnit or not NDuiDB["Nameplate"]["TankMode"] then
		if status and status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status and (status == 2 or status == 1) then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		else
			self.ThreatIndicator:Hide()
		end
	else
		self.ThreatIndicator:Hide()
	end
end

function UF:UpdateThreatColor(_, unit)
	if unit ~= self.unit then return end

	UF.UpdateColor(self, _, unit)
end

function UF:CreateThreatColor(self)
	local threatIndicator = B.CreateSD(self, 3, true)
	threatIndicator:SetOutside(self.Health.backdrop, 3, 3)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatColor
end

-- Target indicator
function UF:UpdateTargetChange()
	local element = self.TargetIndicator
	if NDuiDB["Nameplate"]["TargetIndicator"] == 1 then return end

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		element:SetAlpha(1)
	else
		element:SetAlpha(0)
	end
end

function UF:UpdateTargetIndicator(self)
	local style = NDuiDB["Nameplate"]["TargetIndicator"]
	local element = self.TargetIndicator
	if style == 1 then
		element:Hide()
	else
		if style == 2 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			element.Glow:Hide()
		elseif style == 3 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			element.Glow:Hide()
		elseif style == 4 then
			element.TopArrow:Hide()
			element.RightArrow:Hide()
			element.Glow:Show()
		elseif style == 5 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			element.Glow:Show()
		elseif style == 6 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			element.Glow:Show()
		end
		element:Show()
	end
end

function UF:AddTargetIndicator(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()
	frame:SetFrameLevel(0)
	frame:SetAlpha(0)

	frame.TopArrow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	frame.TopArrow:SetSize(50, 50)
	frame.TopArrow:SetTexture(DB.arrowTex)
	frame.TopArrow:SetPoint("BOTTOM", frame, "TOP", 0, 20)

	frame.RightArrow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	frame.RightArrow:SetSize(50, 50)
	frame.RightArrow:SetTexture(DB.arrowTex)
	frame.RightArrow:SetPoint("LEFT", frame, "RIGHT", 3, 0)
	frame.RightArrow:SetRotation(rad(-90))

	frame.Glow = B.CreateSD(frame, 5, true)
	frame.Glow:SetOutside(self.Health.backdrop, 5, 5)
	frame.Glow:SetBackdropBorderColor(1, 1, 1)
	frame.Glow:SetFrameLevel(0)

	self.TargetIndicator = frame
	UF:UpdateTargetIndicator(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetChange, true)
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function UF:QuestIconCheck()
	if not NDuiDB["Nameplate"]["QuestIndicator"] then return end

	CheckInstanceStatus()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

local unitTip = CreateFrame("GameTooltip", "NDuiQuestUnitTip", nil, "GameTooltipTemplate")
function UF:UpdateQuestUnit(_, unit)
	if not NDuiDB["Nameplate"]["QuestIndicator"] then return end
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	unitTip:SetOwner(UIParent, "ANCHOR_NONE")
	unitTip:SetUnit(unit)

	for i = 2, unitTip:NumLines() do
		local textLine = _G[unitTip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = strmatch(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == DB.MyName then
					local current, goal = strmatch(progressText, "(%d+)/(%d+)")
					local progress = strmatch(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas(DB.objectTex)
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas(DB.questTex)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function UF:UpdateForQuestie(name)
	local data = name and QuestieTooltips.tooltipLookup["u_"..name]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			local questID = tooltip.Objective.QuestData.Id
			QuestieQuest:UpdateQuest(questID)
			if qCurrentQuestlog[questID] then
				foundObjective = true
				if tooltip.Objective.Needed then
					progressText = tooltip.Objective.Needed - tooltip.Objective.Collected
					if progressText == 0 then
						foundObjective = nil
					end
					break
				end
			end
		end
		if foundObjective then
			self.questIcon:Show()
			self.questCount:SetText(progressText)
		end
	end
end

function UF:UpdateCodexQuestUnit(name)
	if name and CodexMap.tooltips[name] then
		for _, meta in pairs(CodexMap.tooltips[name]) do
			local questData = meta["quest"]
			local quests = CodexDB.quests.loc

			if questData then
				for questIndex = 1, GetNumQuestLogEntries() do
					local _, _, _, header, _, _, _, questId = GetQuestLogTitle(questIndex)
					if not header and quests[questId] and questData == quests[questId].T then
						local objectives = GetNumQuestLeaderBoards(questIndex)
						local foundObjective, progressText = nil
						if objectives then
							for i = 1, objectives do
								local text, type = GetQuestLogLeaderBoard(i, questIndex)
								if type == "monster" then
									local _, _, monsterName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif table.getn(meta["item"]) > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
									for _, item in pairs(meta["item"]) do
										if item == itemName then
											progressText = objNeeded - objNum
											foundObjective = true
											break
										end
									end
								end
							end
						end

						if foundObjective and progressText > 0 then
							self.questIcon:Show()
							self.questCount:SetText(progressText)
						elseif not foundObjective then
							self.questIcon:Show()
						end
					end
				end
			end
		end
	end
end

function UF:UpdateQuestIndicator()
	if not NDuiDB["Nameplate"]["QuestIndicator"] then return end

	self.questIcon:Hide()
	self.questCount:SetText("")

	local name = self.unitName
	if CodexMap then
		UF.UpdateCodexQuestUnit(self, name)
	elseif QuestieTooltips then
		UF.UpdateForQuestie(self, name)
	end
end

function UF:AddQuestIcon(self)
	if not NDuiDB["Nameplate"]["QuestIndicator"] then return end

	local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	qicon:SetPoint("LEFT", self, "RIGHT", 2, 0)
	qicon:SetSize(16, 16)
	qicon:SetAtlas(DB.questTex)
	qicon:Hide()
	local count = B.CreateFS(self, 12, "", nil, "LEFT", 0, 0)
	count:SetPoint("LEFT", qicon, "RIGHT", -2, 0)
	count:SetTextColor(.6, .8, 1)

	self.questIcon = qicon
	self.questCount = count
	--self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
	self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestIndicator, true)
end

-- Unit classification
local classify = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

function UF:AddCreatureIcon(self)
	local iconFrame = CreateFrame("Frame", nil, self)
	iconFrame:SetAllPoints()
	iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAtlas("VignetteKill")
	icon:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -6)
	icon:SetSize(24, 24)
	icon:Hide()

	self.creatureIcon = icon
end

function UF:UpdateUnitClassify(unit)
	local class = UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:Show()
		else
			self.creatureIcon:Hide()
		end
	end
end

-- Mouseover indicator
function UF:IsMouseoverUnit()
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

function UF:UpdateMouseoverShown()
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function UF:MouseoverIndicator(self)
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()
	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetColorTexture(1, 1, 1, .25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UF.UpdateMouseoverShown, true)

	local f = CreateFrame("Frame", nil, self)
	f:SetScript("OnUpdate", function(_, elapsed)
		f.elapsed = (f.elapsed or 0) + elapsed
		if f.elapsed > .1 then
			if not UF.IsMouseoverUnit(self) then
				f:Hide()
			end
			f.elapsed = 0
		end
	end)
	f:HookScript("OnHide", function()
		highlight:Hide()
	end)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = f
end

-- Interrupt info on castbars
local guidToPlate = {}
function UF:UpdateCastbarInterrupt(...)
	local _, eventType, _, sourceGUID, sourceName, _, _, destGUID = ...
	if eventType == "SPELL_INTERRUPT" and destGUID and sourceName and sourceName ~= "" then
		local nameplate = guidToPlate[destGUID]
		if nameplate and nameplate.Castbar then
			local _, class = GetPlayerInfoByGUID(sourceGUID)
			local r, g, b = B.ClassColor(class)
			local color = B.HexRGB(r, g, b)
			local sourceName = Ambiguate(sourceName, "short")
			nameplate.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
			nameplate.Castbar.Time:SetText("")
		end
	end
end

function UF:AddInterruptInfo()
	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.UpdateCastbarInterrupt)
end

-- Create Nameplates
local platesList = {}
function UF:CreatePlates()
	self.mystyle = "nameplate"
	self:SetSize(NDuiDB["Nameplate"]["PlateWidth"], NDuiDB["Nameplate"]["PlateHeight"])
	self:SetPoint("CENTER")
	self:SetScale(NDuiADB["UIScale"])

	local health = CreateFrame("StatusBar", nil, self)
	health:SetAllPoints()
	health:SetStatusBarTexture(DB.normTex)
	health.backdrop = B.CreateBDFrame(health, nil, true) -- don't mess up with libs
	B:SmoothBar(health)

	self.Health = health
	self.Health.frequentUpdates = true
	self.Health.UpdateColor = UF.UpdateColor

	UF:CreateHealthText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
	UF:CreateThreatColor(self)

	self.powerText = B.CreateFS(self, 22)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	UF:MouseoverIndicator(self)
	UF:AddTargetIndicator(self)
	UF:AddCreatureIcon(self)
	UF:AddQuestIcon(self)

	platesList[self] = self:GetName()
end

-- Classpower on target nameplate
local isTargetClassPower
function UF:UpdateClassPowerAnchor()
	if not isTargetClassPower then return end

	local bar = _G.oUF_ClassPowerBar
	local nameplate = C_NamePlate.GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:SetScale(.7)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 26)
		bar:Show()
	else
		bar:Hide()
	end
end

function UF:UpdateTargetClassPower()
	local bar = _G.oUF_ClassPowerBar
	local playerPlate = _G.oUF_PlayerPlate
	if not bar or not playerPlate then return end

	if NDuiDB["Nameplate"]["NameplateClassPower"] then
		isTargetClassPower = true
		UF:UpdateClassPowerAnchor()
	else
		isTargetClassPower = false
		if NDuiDB["Nameplate"]["ClassPowerOnly"] then
			bar:SetParent(UIParent)
		else
			bar:SetParent(playerPlate.Health)
		end
		bar:SetScale(1)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOMLEFT", playerPlate.Health, "TOPLEFT", 0, 3)
		bar:Show()
	end
end

function UF:RefreshAllPlates()
	for nameplate in pairs(platesList) do
		nameplate:SetSize(NDuiDB["Nameplate"]["PlateWidth"], NDuiDB["Nameplate"]["PlateHeight"])
		nameplate.nameText:SetFont(DB.Font[1], NDuiDB["Nameplate"]["NameTextSize"], DB.Font[3])
		nameplate.Castbar.Time:SetFont(DB.Font[1], NDuiDB["Nameplate"]["NameTextSize"], DB.Font[3])
		nameplate.Castbar.Text:SetFont(DB.Font[1], NDuiDB["Nameplate"]["NameTextSize"], DB.Font[3])
		nameplate.healthValue:SetFont(DB.Font[1], NDuiDB["Nameplate"]["HealthTextSize"], DB.Font[3])
		nameplate.healthValue:UpdateTag()
		nameplate.Auras.showDebuffType = NDuiDB["Nameplate"]["ColorBorder"]
		UF:UpdateTargetIndicator(nameplate)
	end
end

function UF:PostUpdatePlates(event, unit)
	if not self then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		if self.unitGUID then
			guidToPlate[self.unitGUID] = self
		end
		self.npcID = B.GetNPCID(self.unitGUID)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if self.unitGUID then
			guidToPlate[self.unitGUID] = nil
		end
	end

	UF.UpdateUnitPower(self)
	UF.UpdateTargetChange(self)
	--UF.UpdateQuestUnit(self, event, unit)
	UF.UpdateQuestIndicator(self)
	UF.UpdateUnitClassify(self, unit)
	UF:UpdateClassPowerAnchor()
end

-- Player Nameplate
local auras = B:GetModule("Auras")

function UF:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, .3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Health.bg, .3, self.Health.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, .3, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Power.bg, .3, self.Power.bg:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), .1)
		UIFrameFadeOut(self.Health.bg, 2, self.Health.bg:GetAlpha(), .1)
		UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), .1)
		UIFrameFadeOut(self.Power.bg, 2, self.Power.bg:GetAlpha(), .1)
	end
end

function UF:ResizePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if plate then
		local iconSize, margin = NDuiDB["Nameplate"]["PPIconSize"], 2
		local pHeight, ppHeight = NDuiDB["Nameplate"]["PPHeight"], NDuiDB["Nameplate"]["PPPHeight"]
		plate:SetSize(iconSize*5 + margin*4, pHeight + ppHeight + C.mult)
		plate.Health:SetHeight(pHeight)
		plate.Power:SetHeight(ppHeight)
		local bars = plate.ClassPower
		if bars then
			for i = 1, 6 do
				bars[i]:SetHeight(pHeight)
			end
		end
	end
end

function UF:TogglePlayerPlateElements()
	if not NDuiDB["Nameplate"]["ClassPowerOnly"] then return end

	local plate = _G.oUF_PlayerPlate
	if plate then
		plate:DisableElement("Health")
		plate:DisableElement("Power")
	end
end

function UF:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"
	self:EnableMouse(false)
	local iconSize, margin = NDuiDB["Nameplate"]["PPIconSize"], 2
	local pHeight, ppHeight = NDuiDB["Nameplate"]["PPHeight"], NDuiDB["Nameplate"]["PPPHeight"]
	self:SetSize(iconSize*5 + margin*4, pHeight + ppHeight + C.mult)

	UF:CreateHealthBar(self)
	UF:CreatePowerBar(self)
	UF:CreateClassPower(self)
	if NDuiDB["Auras"]["ClassAuras"] and not DB.isClassic then auras:CreateLumos(self) end
	if not NDuiDB["Nameplate"]["ClassPowerOnly"] then UF:CreateEneryTicker(self) end

	if NDuiDB["Nameplate"]["PPPowerText"] then
		local textFrame = CreateFrame("Frame", nil, self.Power)
		textFrame:SetAllPoints()
		local power = B.CreateFS(textFrame, 14, "")
		self:Tag(power, "[pppower]")
	end

	UF:UpdateTargetClassPower()

	if NDuiDB["Nameplate"]["PPHideOOC"] and not NDuiDB["Nameplate"]["ClassPowerOnly"] then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
	end
end