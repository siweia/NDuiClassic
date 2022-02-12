local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")
local format, tostring = string.format, tostring

-- Units
local function SetUnitFrameSize(self, unit)
	local width = C.db["UFs"][unit.."Width"]
	local height = C.db["UFs"][unit.."Height"] + C.db["UFs"][unit.."PowerHeight"] + C.mult
	self:SetSize(width, height)
end

local function CreatePlayerStyle(self)
	self.mystyle = "player"
	SetUnitFrameSize(self, "Player")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAddPower(self)
	UF:CreateClassPower(self)
	UF:CreateEneryTicker(self)
	UF:CreateAuras(self)

	if C.db["UFs"]["Castbars"] then
		UF:ReskinMirrorBars()
		--UF:ReskinTimerTrakcer(self)
	end
	if not C.db["Misc"]["ExpRep"] then UF:CreateExpRepBar(self) end
	if C.db["UFs"]["SwingBar"] then UF:CreateSwing(self) end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	SetUnitFrameSize(self, "Player")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAuras(self)
end

local function CreateFocusStyle(self)
	self.mystyle = "focus"
	SetUnitFrameSize(self, "Focus")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
end

local function CreateToTStyle(self)
	self.mystyle = "tot"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateAuras(self)
end

local function CreateToToT(self)
	self.mystyle = "tot"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreateFocusTargetStyle(self)
	self.mystyle = "focustarget"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreateArenaStyle(self)
	self.mystyle = "arena"
	SetUnitFrameSize(self, "Boss")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
--	UF:CreatePVPClassify(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreateTargetBorder(self)
	UF:CreateRaidIcons(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateRaidDebuffs(self)
	UF:CreateThreatBorder(self)
	UF:CreateAuras(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:RefreshAurasByCombat(self)
	UF:CreateBuffIndicator(self)
end

local function CreatePartyStyle(self)
	self.isPartyFrame = true
	CreateRaidStyle(self)
end

local function CreatePartyPetStyle(self)
	self.mystyle = "raid"
	self.isPartyPet = true
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateTargetBorder(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateThreatBorder(self)
end

-- Spawns
local function GetPartyVisibility()
	local visibility = "[group:party,nogroup:raid] show;hide"
	if C.db["UFs"]["SmartRaid"] then
		visibility = "[@raid6,noexists,group] show;hide"
	end
	if C.db["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

local function GetRaidVisibility()
	local visibility
	if C.db["UFs"]["PartyFrame"] then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	else
		if C.db["UFs"]["ShowSolo"] then
			visibility = "show"
		else
			visibility = "[group] show;hide"
		end
	end
	return visibility
end

function UF:UpdateAllHeaders()
	if not UF.headers then return end

	for _, header in pairs(UF.headers) do
		if header.groupType == "party" then
			RegisterStateDriver(header, "visibility", GetPartyVisibility())
		elseif header.groupType == "raid" then
			RegisterStateDriver(header, "visibility", GetRaidVisibility())
		end
	end
end

function UF:OnLogin()
	local horizonRaid = C.db["UFs"]["HorizonRaid"]
	local horizonParty = C.db["UFs"]["HorizonParty"]
	local numGroups = C.db["UFs"]["NumGroups"]
	local scale = C.db["UFs"]["SimpleRaidScale"]/10
	local raidWidth, raidHeight = C.db["UFs"]["RaidWidth"], C.db["UFs"]["RaidHeight"]
	local partyWidth, partyHeight = C.db["UFs"]["PartyWidth"], C.db["UFs"]["PartyHeight"]
	local petWidth, petHeight = C.db["UFs"]["PartyPetWidth"], C.db["UFs"]["PartyPetHeight"]
	local showTeamIndex = C.db["UFs"]["ShowTeamIndex"]

	if C.db["Nameplate"]["Enable"] then
		UF:SetupCVars()
		UF:BlockAddons()
		UF:CreateUnitTable()
		UF:CreatePowerUnitTable()
		UF:QuestIconCheck()
		UF:RefreshPlateOnFactionChanged()
		UF:RefreshMajorSpells()

		oUF:RegisterStyle("Nameplates", UF.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", UF.PostUpdatePlates)
	end

	do -- a playerplate-like PlayerFrame
		oUF:RegisterStyle("PlayerPlate", UF.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = B.Mover(plate, L["PlayerPlate"], "PlayerPlate", C.UFs.PlayerPlate)
		UF:TogglePlayerPlate()
	end

	do	-- fake nameplate for target class power
		oUF:RegisterStyle("TargetPlate", UF.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		UF:ToggleTargetClassPower()
	end

	-- Default Clicksets for RaidFrame
	UF:DefaultClickSets()

	if C.db["UFs"]["Enable"] then
		-- Register
		oUF:RegisterStyle("Player", CreatePlayerStyle)
		oUF:RegisterStyle("Target", CreateTargetStyle)
		oUF:RegisterStyle("ToT", CreateToTStyle)
		--oUF:RegisterStyle("Focus", CreateFocusStyle)
		oUF:RegisterStyle("FocusTarget", CreateFocusTargetStyle)
		oUF:RegisterStyle("Pet", CreatePetStyle)

		-- Loader
		oUF:SetActiveStyle("Player")
		local player = oUF:Spawn("player", "oUF_Player")
		B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos)
		UF.ToggleCastBar(player, "Player")

		oUF:SetActiveStyle("Target")
		local target = oUF:Spawn("target", "oUF_Target")
		B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos)
		UF.ToggleCastBar(target, "Target")

		oUF:SetActiveStyle("ToT")
		local targettarget = oUF:Spawn("targettarget", "oUF_ToT")
		B.Mover(targettarget, L["TotUF"], "TotUF", C.UFs.ToTPos)

		oUF:SetActiveStyle("Pet")
		local pet = oUF:Spawn("pet", "oUF_Pet")
		B.Mover(pet, L["PetUF"], "PetUF", C.UFs.PetPos)
--[[
		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos)
		UF.ToggleCastBar(focus, "Focus")

		oUF:SetActiveStyle("FocusTarget")
		local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		B.Mover(focustarget, L["FotUF"], "FotUF", {"TOPLEFT", oUF_Focus, "TOPRIGHT", 5, 0})]]

		if C.db["UFs"]["ToToT"] then
			oUF:RegisterStyle("ToToT", CreateToToT)
			oUF:SetActiveStyle("ToToT")
			local targettargettarget = oUF:Spawn("targettargettarget", "oUF_ToToT")
			B.Mover(targettargettarget, L["TototUF"], "TototUF", C.UFs.ToToTPos)
		end
--[[
		if C.db["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				local moverWidth, moverHeight = arena[i]:GetWidth(), arena[i]:GetHeight()+8
				if i == 1 then
					arena[i].mover = B.Mover(arena[i], L["ArenaFrame"]..i, "Arena1", {"RIGHT", UIParent, "RIGHT", -350, -90}, moverWidth, moverHeight)
				else
					arena[i].mover = B.Mover(arena[i], L["ArenaFrame"]..i, "Arena"..i, {"BOTTOM", arena[i-1], "TOP", 0, 50}, moverWidth, moverHeight)
				end
			end
		end]]

		UF:ToggleUFClassPower()
		UF:UpdateTextScale()
		UF:ToggleAllAuras()
	end

	if C.db["UFs"]["RaidFrame"] then
		UF:AddClickSetsListener()
		UF:UpdateCornerSpells()
		UF:BuildNameListFromID()
		UF.headers = {}

		-- Hide Default RaidFrame
		if CompactRaidFrameManager_SetSetting then
			CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(B.HiddenFrame)
		end

		-- Group Styles
		if C.db["UFs"]["PartyFrame"] then
			oUF:RegisterStyle("Party", CreatePartyStyle)
			oUF:SetActiveStyle("Party")

			local xOffset, yOffset = 5, 5
			local partyFrameHeight = partyHeight + C.db["UFs"]["PartyPowerHeight"] + C.mult
			local moverWidth = horizonParty and (partyWidth*5+xOffset*4) or partyWidth
			local moverHeight = horizonParty and partyFrameHeight or (partyFrameHeight*5+yOffset*4)
			local groupingOrder = horizonParty and "TANK,HEALER,DAMAGER,NONE" or "NONE,DAMAGER,HEALER,TANK"

			local party = oUF:SpawnHeader("oUF_Party", nil, nil,
			"showPlayer", true,
			"showSolo", true,
			"showParty", true,
			"showRaid", true,
			"xoffset", xOffset,
			"yOffset", yOffset,
			"groupingOrder", groupingOrder,
			"groupBy", "ASSIGNEDROLE",
			"sortMethod", "NAME",
			"point", horizonParty and "LEFT" or "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			]]):format(partyWidth, partyFrameHeight))

			party.groupType = "party"
			tinsert(UF.headers, party)
			RegisterStateDriver(party, "visibility", GetPartyVisibility())

			local partyMover = B.Mover(party, L["PartyFrame"], "PartyFrame", {"LEFT", UIParent, 350, 0}, moverWidth, moverHeight)
			party:ClearAllPoints()
			party:SetPoint("BOTTOMLEFT", partyMover)

			if C.db["UFs"]["PartyPetFrame"] then
				oUF:RegisterStyle("PartyPet", CreatePartyPetStyle)
				oUF:SetActiveStyle("PartyPet")

				local petFrameHeight = petHeight + C.db["UFs"]["PartyPetPowerHeight"] + C.mult
				local petMoverWidth = horizonParty and (petWidth*5+xOffset*4) or petWidth
				local petMoverHeight = horizonParty and petFrameHeight or (petFrameHeight*5+yOffset*4)

				local partyPet = oUF:SpawnHeader("oUF_PartyPet", nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", xOffset,
				"yOffset", yOffset,
				"point", horizonParty and "LEFT" or "BOTTOM",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				self:SetAttribute("unitsuffix", "pet")
				]]):format(petWidth, petFrameHeight))

				partyPet.groupType = "party"
				tinsert(UF.headers, partyPet)
				RegisterStateDriver(partyPet, "visibility", GetPartyVisibility())

				local moverAnchor = horizonParty and {"TOPLEFT", partyMover, "BOTTOMLEFT", 0, -20} or {"BOTTOMRIGHT", partyMover, "BOTTOMLEFT", -10, 0}
				local petMover = B.Mover(partyPet, L["PartyPetFrame"], "PartyPetFrame", moverAnchor, petMoverWidth, petMoverHeight)
				partyPet:ClearAllPoints()
				partyPet:SetPoint("BOTTOMLEFT", petMover)
			end
		end

		oUF:RegisterStyle("Raid", CreateRaidStyle)
		oUF:SetActiveStyle("Raid")

		if C.db["UFs"]["SimpleMode"] then
			local unitsPerColumn = C.db["UFs"]["SMUnitsPerColumn"]
			local maxColumns = B:Round(numGroups*5 / unitsPerColumn)

			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -5,
				"groupFilter", tostring(i),
				"maxColumns", maxColumns,
				"unitsPerColumn", unitsPerColumn,
				"columnSpacing", 5,
				"point", "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(100*scale, 20*scale))
				return group
			end

			local groupFilter
			if numGroups == 4 then
				groupFilter = "1,2,3,4"
			elseif numGroups == 5 then
				groupFilter = "1,2,3,4,5"
			elseif numGroups == 6 then
				groupFilter = "1,2,3,4,5,6"
			elseif numGroups == 7 then
				groupFilter = "1,2,3,4,5,6,7"
			elseif numGroups == 8 then
				groupFilter = "1,2,3,4,5,6,7,8"
			end

			local group = CreateGroup("oUF_Raid", groupFilter)
			group.groupType = "raid"
			tinsert(UF.headers, group)
			RegisterStateDriver(group, "visibility", GetRaidVisibility())

			local moverWidth = 100*scale*maxColumns + 5*(maxColumns-1)
			local moverHeight = 20*scale*unitsPerColumn + 5*(unitsPerColumn-1)
			B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, moverWidth, moverHeight)

			local groupByTypes = {
				[1] = {"1,2,3,4,5,6,7,8", "GROUP", "INDEX"},
				[2] = {"WARRIOR,ROGUE,PALADIN,DRUID,SHAMAN,HUNTER,PRIEST,MAGE,WARLOCK", "CLASS", "NAME"},
			}
			function UF:UpdateSimpleModeHeader()
				local groupByIndex = C.db["UFs"]["SMGroupByIndex"]
				group:SetAttribute("groupingOrder", groupByTypes[groupByIndex][1])
				group:SetAttribute("groupBy", groupByTypes[groupByIndex][2])
				group:SetAttribute("sortMethod", groupByTypes[groupByIndex][3])
			end
			UF:UpdateSimpleModeHeader()
		else
			local raidFrameHeight = raidHeight + C.db["UFs"]["RaidPowerHeight"] + C.mult

			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -5,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizonRaid and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(raidWidth, raidFrameHeight))
				return group
			end

			local groups = {}
			for i = 1, numGroups do
				groups[i] = CreateGroup("oUF_Raid"..i, i)
				groups[i].groupType = "raid"
				tinsert(UF.headers, groups[i])
				RegisterStateDriver(groups[i], "visibility", "show")
				RegisterStateDriver(groups[i], "visibility", GetRaidVisibility())

				if i == 1 then
					if horizonRaid then
						groups[i].mover = B.Mover(groups[i], L["RaidFrame"]..i, "RaidFrame"..i, {"TOPLEFT", UIParent, 35, -50}, (raidWidth+5)*5, raidFrameHeight)
					else
						groups[i].mover = B.Mover(groups[i], L["RaidFrame"]..i, "RaidFrame"..i, {"TOPLEFT", UIParent, 35, -50}, raidWidth, raidFrameHeight*5)
					end
				else
					if horizonRaid then
						groups[i].mover = B.Mover(groups[i], L["RaidFrame"]..i, "RaidFrame"..i, {"TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, showTeamIndex and -25 or -15}, (raidWidth+5)*5, raidFrameHeight)
					else
						groups[i].mover = B.Mover(groups[i], L["RaidFrame"]..i, "RaidFrame"..i, {"TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0}, raidWidth, raidFrameHeight*5)
					end
				end

				if showTeamIndex then
					local parent = _G["oUF_Raid"..i.."UnitButton1"]
					local teamIndex = B.CreateFS(parent, 12, format(GROUP_NUMBER, i))
					teamIndex:ClearAllPoints()
					teamIndex:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 5)
					teamIndex:SetTextColor(.6, .8, 1)
				end
			end
		end

		UF:UpdateRaidHealthMethod()
	end
end