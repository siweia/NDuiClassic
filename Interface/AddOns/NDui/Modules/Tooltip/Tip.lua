local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local TT = B:RegisterModule("Tooltip")

local strfind, format, strupper, strlen, pairs, unpack = string.find, string.format, string.upper, string.len, pairs, unpack
local ICON_LIST, BAG_ITEM_QUALITY_COLORS = ICON_LIST, BAG_ITEM_QUALITY_COLORS
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND
local InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo = InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, GetGuildInfo, IsInGuild = GetRaidTargetIndex, GetGuildInfo, IsInGuild

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}

function TT:GetUnit()
	local _, unit = self and self:GetUnit()
	if not unit then
		local mFocus = GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit"))) or "mouseover"
	end
	return unit
end

function TT:HideLines()
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext then
			if linetext == PVP then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				if NDuiDB["Tooltip"]["FactionIcon"] then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cffff5040"..linetext.."|r")
				end
			elseif linetext == FACTION_ALLIANCE then
				if NDuiDB["Tooltip"]["FactionIcon"] then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cff4080ff"..linetext.."|r")
				end
			end
		end
    end
end

function TT:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext
		end
	end
end

function TT:GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return format("|cffff0000%s|r", ">"..strupper(YOU).."<")
	else
		return B.HexRGB(B.UnitColor(unit))..UnitName(unit).."|r"
	end
end

function TT:InsertFactionFrame(faction)
	if not self.factionFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", 0, -5)
		f:SetBlendMode("ADD")
		f:SetScale(.3)
		self.factionFrame = f
	end
	self.factionFrame:SetTexture("Interface\\Timer\\"..faction.."-Logo")
	self.factionFrame:SetAlpha(.5)
end

function TT:OnTooltipCleared()
	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end
end

function TT:OnTooltipSetUnit()
	if self:IsForbidden() then return end
	if NDuiDB["Tooltip"]["CombatHide"] and InCombatLockdown() then self:Hide() return end
	TT.HideLines(self)

	local unit = TT.GetUnit(self)
	local isShiftKeyDown = IsShiftKeyDown()
	if UnitExists(unit) then
		local r, g, b = B.UnitColor(unit)
		local hexColor = B.HexRGB(r, g, b)
		local ricon = GetRaidTargetIndex(unit)
		local text = GameTooltipTextLeft1:GetText()
		if ricon and ricon > 8 then ricon = nil end
		if ricon and text then
			GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."18|t", text)
		end

		local isPlayer = UnitIsPlayer(unit)
		if isPlayer then
			local name, realm = UnitName(unit)
			local pvpName = UnitPVPName(unit)
			local relationship = UnitRealmRelationship(unit)
			if not NDuiDB["Tooltip"]["HideTitle"] and pvpName then
				name = pvpName
			end
			if realm and realm ~= "" then
				if isShiftKeyDown or not NDuiDB["Tooltip"]["HideRealm"] then
					name = name.."-"..realm
				elseif relationship == LE_REALM_RELATION_COALESCED then
					name = name..FOREIGN_SERVER_LABEL
				elseif relationship == LE_REALM_RELATION_VIRTUAL then
					name = name..INTERACTIVE_SERVER_LABEL
				end
			end

			local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
			if status then
				status = format(" |cffffcc00[%s]|r", status)
			end
			GameTooltipTextLeft1:SetFormattedText("%s", name..(status or ""))

			if NDuiDB["Tooltip"]["FactionIcon"] then
				local faction = UnitFactionGroup(unit)
				if faction and faction ~= "Neutral" then
					TT.InsertFactionFrame(self, faction)
				end
			end

			local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
			local hasText = GameTooltipTextLeft2:GetText()
			if guildName and hasText then
				local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
				if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
					GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
				else
					GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
				end

				rankIndex = rankIndex + 1
				if NDuiDB["Tooltip"]["HideRank"] then rank = "" end
				if guildRealm and isShiftKeyDown then
					guildName = guildName.."-"..guildRealm
				end
				if NDuiDB["Tooltip"]["HideJunkGuild"] and not isShiftKeyDown then
					if strlen(guildName) > 31 then guildName = "..." end
				end
				GameTooltipTextLeft2:SetText("<"..guildName.."> "..rank.."("..rankIndex..")")
			end
		end

		local alive = not UnitIsDeadOrGhost(unit)
		local level = UnitLevel(unit)

		if level then
			local boss
			if level == -1 then boss = "|cffff0000??|r" end

			local diff = GetCreatureDifficultyColor(level)
			local classify = UnitClassification(unit)
			local textLevel = format("%s%s%s|r", B.HexRGB(diff), boss or format("%d", level), classification[classify] or "")
			local tiptextLevel = TT.GetLevelLine(self)
			if tiptextLevel then
				local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
				local unitClass = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor..(UnitClass(unit) or "").."|r") or UnitCreatureType(unit) or ""
				tiptextLevel:SetFormattedText(("%s%s %s %s"), textLevel, pvpFlag, unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
			end
		end

		if UnitExists(unit.."target") then
			local tarRicon = GetRaidTargetIndex(unit.."target")
			if tarRicon and tarRicon > 8 then tarRicon = nil end
			local tar = format("%s%s", (tarRicon and ICON_LIST[tarRicon].."10|t") or "", TT:GetTarget(unit.."target"))
			self:AddLine(TARGET..": "..tar)
		end

		GameTooltipTextLeft1:SetTextColor(r, g, b)
		if alive then
			GameTooltipStatusBar:SetStatusBarColor(r, g, b)
		else
			GameTooltipStatusBar:Hide()
		end
	else
		GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
	end

	--TT.InspectUnitSpecAndLevel(self)
end

function TT:StatusBar_OnValueChanged(value)
	if self:IsForbidden() or not value then return end
	local min, max = self:GetMinMaxValues()
	if (value < min) or (value > max) then return end

	if not self.text then
		self.text = B.CreateFS(self, 12, "")
	end

	if value > 0 and max == 1 then
		self.text:SetFormattedText("%d%%", value*100)
	else
		self.text:SetText(B.Numb(value).." | "..B.Numb(max))
	end
end

function TT:ReskinStatusBar()
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", C.mult, 3)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -C.mult, 3)
	GameTooltipStatusBar:SetStatusBarTexture(DB.normTex)
	GameTooltipStatusBar:SetHeight(5)
	local bg = B.CreateBG(GameTooltipStatusBar)
	B.CreateBD(bg, .7)
	B.CreateSD(bg)
	B.CreateTex(bg)
end

function TT:GameTooltip_ShowStatusBar()
	if self.statusBarPool then
		local bar = self.statusBarPool:Acquire()
		if bar and not bar.styled then
			B.StripTextures(bar)
			local tex = select(3, bar:GetRegions())
			tex:SetTexture(DB.normTex)
			B.CreateBD(B.CreateBG(bar), .25)

			bar.styled = true
		end
	end
end

function TT:GameTooltip_ShowProgressBar()
	if self.progressBarPool then
		local bar = self.progressBarPool:Acquire()
		if bar and not bar.styled then
			B.StripTextures(bar.Bar)
			bar.Bar:SetStatusBarTexture(DB.normTex)
			B.CreateBD(B.CreateBG(bar.Bar), .25)

			bar.styled = true
		end
	end
end

-- Anchor and mover
local mover
function TT:GameTooltip_SetDefaultAnchor(parent)
	if NDuiDB["Tooltip"]["Cursor"] then
		self:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
	else
		if not mover then
			mover = B.Mover(self, L["Tooltip"], "GameTooltip", C.Tooltips.TipPos, 240, 120)
		end
		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", mover)
	end
end

-- Tooltip skin
local function getBackdrop(self) return self.bg:GetBackdrop() end
local function getBackdropColor() return 0, 0, 0, .7 end
local function getBackdropBorderColor() return 0, 0, 0 end

function TT:ReskinTooltip()
	if not self then
		if DB.isDeveloper then print("Unknown tooltip spotted.") end
		return
	end
	if self:IsForbidden() then return end
	self:SetScale(NDuiDB["Tooltip"]["Scale"])

	if not self.tipStyled then
		self:SetBackdrop(nil)
		self:DisableDrawLayer("BACKGROUND")
		local bg = B.CreateBG(self, 0)
		bg:SetFrameLevel(self:GetFrameLevel())
		B.CreateBD(bg, .7)
		B.CreateSD(bg)
		B.CreateTex(bg)
		self.bg = bg

		-- other gametooltip-like support
		self.GetBackdrop = getBackdrop
		self.GetBackdropColor = getBackdropColor
		self.GetBackdropBorderColor = getBackdropBorderColor

		self.tipStyled = true
	end

	self.bg.Shadow:SetBackdropBorderColor(0, 0, 0)
	if NDuiDB["Tooltip"]["ClassColor"] and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			if color then
				self.bg.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end

	if self.NumLines and self:NumLines() > 0 then
		for index = 1, self:NumLines() do
			if index == 1 then
				_G[self:GetName().."TextLeft"..index]:SetFont(DB.TipFont[1], DB.TipFont[2] + 2, DB.TipFont[3])
			else
				_G[self:GetName().."TextLeft"..index]:SetFont(unpack(DB.TipFont))
			end
			_G[self:GetName().."TextRight"..index]:SetFont(unpack(DB.TipFont))
		end
	end
end

function TT:GameTooltip_SetBackdropStyle()
	if not self.tipStyled then return end
	self:SetBackdrop(nil)
end

function TT:OnLogin()
	self:ReskinStatusBar()
	GameTooltip:HookScript("OnTooltipCleared", self.OnTooltipCleared)
	GameTooltip:HookScript("OnTooltipSetUnit", self.OnTooltipSetUnit)
	GameTooltipStatusBar:SetScript("OnValueChanged", self.StatusBar_OnValueChanged)
	hooksecurefunc("GameTooltip_ShowStatusBar", self.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", self.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", self.GameTooltip_SetDefaultAnchor)
	hooksecurefunc("GameTooltip_SetBackdropStyle", self.GameTooltip_SetBackdropStyle)

	-- Elements
	self:ReskinTooltipIcons()
	self:SetupTooltipID()
	self:TargetedInfo()
end

-- Tooltip Skin Registration
local tipTable = {}
function TT:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
B:RegisterEvent("ADDON_LOADED", addonStyled)

TT:RegisterTooltips("NDui", function()
	if F then
		AuroraOptionstooltips:SetAlpha(0)
		AuroraOptionstooltips:Disable()
		AuroraConfig.tooltips = false
	end

	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		GeneralDockManagerOverflowButtonList,
		NamePlateTooltip,
		IMECandidatesFrame
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", TT.ReskinTooltip)
	end

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({"DropDownList", "L_DropDownList", "Lib_DropDownList"}) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name..i.."MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", TT.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	local r, g, b = DB.r, DB.g, DB.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Others
	C_Timer.After(5, function()
		-- Lib minimap icon
		if LibDBIconTooltip then
			TT.ReskinTooltip(LibDBIconTooltip)
		end
		-- TomTom
		if TomTomTooltip then
			TT.ReskinTooltip(TomTomTooltip)
		end
		-- RareScanner
		if RSMapItemToolTip then
			TT.ReskinTooltip(RSMapItemToolTip)
		end
		if LootBarToolTip then
			TT.ReskinTooltip(LootBarToolTip)
		end
	end)
end)

TT:RegisterTooltips("Blizzard_DebugTools", function()
	TT.ReskinTooltip(FrameStackTooltip)
	TT.ReskinTooltip(EventTraceTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
	EventTraceTooltip:SetParent(UIParent)
	EventTraceTooltip:SetFrameStrata("TOOLTIP")
end)