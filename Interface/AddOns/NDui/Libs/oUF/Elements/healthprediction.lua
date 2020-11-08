--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

myBar          - A `StatusBar` used to represent incoming heals from the player.
otherBar       - A `StatusBar` used to represent incoming heals from others.
absorbBar      - A `StatusBar` used to represent damage absorbs.
healAbsorbBar  - A `StatusBar` used to represent heal absorbs.
overAbsorb     - A `Texture` used to signify that the amount of damage absorb is greater than the unit's missing health.
overHealAbsorb - A `Texture` used to signify that the amount of heal absorb is greater than the unit's current health.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.maxOverflow     - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                   Defaults to 1.05 (number)
.frequentUpdates - Indicates whether to use UNIT_HEALTH_FREQUENT instead of UNIT_HEALTH. Use this if .frequentUpdates is
                   also set on the Health element (boolean)

## Examples

    -- Position and size
    local myBar = CreateFrame('StatusBar', nil, self.Health)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetWidth(200)

    local otherBar = CreateFrame('StatusBar', nil, self.Health)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetWidth(200)

    local absorbBar = CreateFrame('StatusBar', nil, self.Health)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), 'RIGHT')
    absorbBar:SetWidth(200)

    -- Register with oUF
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        maxOverflow = 1.05,
        frequentUpdates = true,
    }
--]]

local _, ns = ...
local oUF = ns.oUF
local myGUID = UnitGUID('player')
local HealComm = LibStub("LibHealComm-4.0")

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.HealthPrediction

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local guid = UnitGUID(unit)

	local allIncomingHeal = HealComm:GetHealAmount(guid, element.healType) or 0
	local myIncomingHeal = (HealComm:GetHealAmount(guid, element.healType, nil, myGUID) or 0) * (HealComm:GetHealModifier(myGUID) or 1)
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local otherIncomingHeal = 0

	if(health + allIncomingHeal > maxHealth * element.maxOverflow) then
		allIncomingHeal = maxHealth * element.maxOverflow - health
	end

	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
	else
		otherIncomingHeal = allIncomingHeal - myIncomingHeal
		--otherIncomingHeal = HealComm:GetOthersHealAmount(guid, HealComm.ALL_HEALS) or 0
	end

	if UnitIsDeadOrGhost(unit) then
		myIncomingHeal, otherIncomingHeal = 0, 0
	end

	if(element.myBar) then
		element.myBar:SetMinMaxValues(0, maxHealth)
		element.myBar:SetValue(myIncomingHeal)
		element.myBar:Show()
	end

	if(element.otherBar) then
		element.otherBar:SetMinMaxValues(0, maxHealth)
		element.otherBar:SetValue(otherIncomingHeal)
		element.otherBar:Show()
	end

	--[[ Callback: HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* myIncomingHeal    - the amount of incoming healing done by the player (number)
	* otherIncomingHeal - the amount of incoming healing done by others (number)
	--]]
	if(element.PostUpdate) then
		-- return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
		return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal)
	end
end

local function Path(self, ...)
	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.HealthPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HealthPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.healType = element.healType or HealComm.ALL_HEALS

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)

		local function HealCommUpdate(...)
			if self.HealthPrediction and self:IsVisible() then
				for i = 1, select('#', ...) do
					if self.unit and UnitGUID(self.unit) == select(i, ...) then
						Path(self, nil, self.unit)
					end
				end
			end
		end

		local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
			HealCommUpdate(...)
		end

		local function HealComm_Modified(event, guid)
			HealCommUpdate(guid)
		end

		HealComm.RegisterCallback(element, 'HealComm_HealStarted', HealComm_Heal_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealUpdated', HealComm_Heal_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealDelayed', HealComm_Heal_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealStopped', HealComm_Heal_Update)
		HealComm.RegisterCallback(element, 'HealComm_ModifierChanged', HealComm_Modified)
		HealComm.RegisterCallback(element, 'HealComm_GUIDDisappeared', HealComm_Modified)

		if(not element.maxOverflow) then
			element.maxOverflow = 1.05
		end

		if(element.myBar) then
			if(element.myBar:IsObjectType('StatusBar') and not element.myBar:GetStatusBarTexture()) then
				element.myBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.otherBar) then
			if(element.otherBar:IsObjectType('StatusBar') and not element.otherBar:GetStatusBarTexture()) then
				element.otherBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.HealthPrediction
	if(element) then
		if(element.myBar) then
			element.myBar:Hide()
		end

		if(element.otherBar) then
			element.otherBar:Hide()
		end

		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
	end
end

oUF:AddElement('HealthPrediction', Path, Enable, Disable)