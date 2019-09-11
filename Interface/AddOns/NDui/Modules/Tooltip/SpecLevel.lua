local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

-- Credit: Cloudy Unit Info, by Cloudyfa
local select, max, strfind, format, strsplit = select, math.max, string.find, string.format, string.split
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown
local UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel = GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel
local GetSpecialization, GetSpecializationInfo, GetInspectSpecialization, GetSpecializationInfoByID = GetSpecialization, GetSpecializationInfo, GetInspectSpecialization, GetSpecializationInfoByID
local HEIRLOOMS, LE_ITEM_QUALITY_HEIRLOOM = HEIRLOOMS, LE_ITEM_QUALITY_HEIRLOOM

local specPrefix = SPECIALIZATION..": "..DB.InfoColor
local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local cache, weapon, currentUNIT, currentGUID = {}, {}

function TT:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			B:RegisterEvent("INSPECT_READY", TT.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", TT.InspectOnUpdate)
updater:Hide()

function TT:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end
B:RegisterEvent("MODIFIER_STATE_CHANGED", TT.ResetUnit)

function TT:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if UnitGUID(unit) == currentGUID then
			TT:InspectUnit(unit, true)
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local level = TT:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if level then
				TT:SetupSpecLevel(level)
			else
				TT:InspectUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(self, TT.GetInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", TT.GetInspectInfo)

function TT:SetupSpecLevel(_, level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()
		if text and strfind(text, levelPrefix) then
			levelLine = line
		end
	end

	level = levelPrefix..(level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
end

function TT:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand = 0, 0, 0, 0, 0
	local delay, mainhand, offhand
	weapon[1], weapon[2] = 0, 0

	for i = 1, 17 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == LE_ITEM_QUALITY_HEIRLOOM then
							boa = boa + 1
						end

						if i < 16 then
							total = total + level
						end

						if i == 16 then
							weapon[1] = level
							haveWeapon = haveWeapon + 1
							if slot == "INVTYPE_2HWEAPON" or slot == "INVTYPE_RANGED" or (slot == "INVTYPE_RANGEDRIGHT" and class == "HUNTER") then
								mainhand = true
								twohand = twohand + 1
							end
						elseif i == 17 then
							weapon[2] = level
							haveWeapon = haveWeapon + 1
							if slot == "INVTYPE_2HWEAPON" then
								offhand = true
								twohand = twohand + 1
							end
						end
					end
				end
			end
		end
	end

	if not delay then
		if twohand == 2 then
			local higher = max(weapon[1], weapon[2])
			total = total + higher*2
		elseif twohand == 1 and haveWeapon == 1 then
			total = total + weapon[1]*2 + weapon[2]*2
		elseif twohand == 1 and haveWeapon == 2 then
			if mainhand and weapon[1] >= weapon[2] then
				total = total + weapon[1]*2
			elseif offhand and weapon[2] >= weapon[1] then
				total = total + weapon[2]*2
			else
				total = total + weapon[1] + weapon[2]
			end
		else
			total = total + weapon[1] + weapon[2]
		end
		ilvl = total / 16

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
		if boa > 0 then ilvl = ilvl.." |cff00ccff("..boa..HEIRLOOMS..")" end
	else
		ilvl = nil
	end

	return ilvl
end

function TT:InspectUnit(unit, forced)
	local level

	if UnitIsUnit(unit, "player") then
		level = self:GetUnitItemLevel("player")
		self:SetupSpecLevel(nil, level)
	else
		if not unit or UnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		level = currentDB.level
		self:SetupSpecLevel(nil, level)

		if not NDuiDB["Tooltip"]["SpecLevelByShift"] and IsShiftKeyDown() then forced = true end
		if level and not forced and (GetTime() - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		self:SetupSpecLevel()
		updater:Show()
	end
end

function TT:InspectUnitSpecAndLevel()
	if NDuiDB["Tooltip"]["SpecLevelByShift"] and not IsShiftKeyDown() then return end

	local _, unit = self:GetUnit()
	if not unit or not CanInspect(unit) then return end

	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	TT:InspectUnit(unit)
end