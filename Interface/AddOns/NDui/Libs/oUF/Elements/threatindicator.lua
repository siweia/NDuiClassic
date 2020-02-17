--[[
# Element: Threat Indicator

Handles the visibility and updating of an indicator based on the unit's current threat level.

## Widget

ThreatIndicator - A `Texture` used to display the current threat level.
The element works by changing the texture's vertex color.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Options

.feedbackUnit - The unit whose threat situation is being requested. If defined, it'll be passed as the first argument to
                [UnitThreatSituation](https://wow.gamepedia.com/API_UnitThreatSituation).

## Examples

    -- Position and size
    local ThreatIndicator = self:CreateTexture(nil, 'OVERLAY')
    ThreatIndicator:SetSize(16, 16)
    ThreatIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.ThreatIndicator = ThreatIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitExists = Private.unitExists

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.ThreatIndicator
	--[[ Callback: ThreatIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the ThreatIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit) end

	unit = unit or self.unit

	local status

	if(unitExists(unit) and UnitIsFriend("player", unit)) then
		if(UnitIsUnit(unit, "targettarget") and UnitIsEnemy("player", "target")) then
			status = true
		end
		if(IsInGroup() and not status) then
			for i=1,GetNumGroupMembers() do
				local target = IsInRaid() and "raid"..i.."target" or "party"..i.."target"
				if(UnitIsUnit(unit, target.."target") and UnitIsEnemy("player", target)) then
					status = true
					break
				end
			end
		end
	end

	if(status) then
		if(element.SetVertexColor) then
			element:SetVertexColor(1, 0, 0)
		end

		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: ThreatIndicator:PostUpdate(unit, status, r, g, b)
	Called after the element has been updated.

	* self   - the ThreatIndicator element
	* unit   - the unit for which the update has been triggered (string)
	* status - the unit's threat status (see [UnitThreatSituation](http://wowprogramming.com/docs/api/UnitThreatSituation.html))
	* r      - the red color component based on the unit's threat status (number?)[0-1]
	* g      - the green color component based on the unit's threat status (number?)[0-1]
	* b      - the blue color component based on the unit's threat status (number?)[0-1]
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, status, 1, 0, 0)
	end
end

local function Path(self, ...)
	--[[ Override: ThreatIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ThreatIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ThreatIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_AURA", Path)
		self:RegisterEvent("UNIT_HEALTH_FREQUENT", Path)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\RAIDFRAME\UI-RaidFrame-Threat]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.ThreatIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent("UNIT_AURA", Path)
		self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Path)
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Path)
	end
end

oUF:AddElement('ThreatIndicator', Path, Enable, Disable)