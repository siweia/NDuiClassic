local _, ns = ...
local oUF = ns.oUF

local max = math.max
local UnitPowerType, UnitPower, GetTime = UnitPowerType, UnitPower, GetTime

local SPELL_POWER_MANA = Enum.PowerType.Mana or 0
local SPELL_POWER_ENERGY = Enum.PowerType.Energy or 3
local lastEnergyTickTime = GetTime()
local lastEnergyValue = 0
local isWaiting

local requireTypes = {
	[SPELL_POWER_MANA] = true,
	[SPELL_POWER_ENERGY] = true,
}

local function SetEnergyTickValue(self, timer, isWaiting)
	local Power = self.Power
	local Width = Power:GetWidth()
	local Texture = self.EnergyTicker.Texture

	if isWaiting then
		local Width = max(Width-(Width * timer) / 5, 0)
		Texture:SetPoint("CENTER", Power, "LEFT", Width, 0)
	else
		Texture:SetPoint("CENTER", Power, "LEFT", (Width * timer) / 2, 0)
	end
end

local function Update(self)
	local powerType = UnitPowerType("player")
	local EnergyTicker = self.EnergyTicker

	if not requireTypes[powerType] then
		EnergyTicker:SetAlpha(0)
		return
	else
		EnergyTicker:SetAlpha(1)
	end

	local CurrentEnergy = UnitPower("player", powerType)

	local Now = GetTime()
	local Timer = Now - lastEnergyTickTime

	if powerType == SPELL_POWER_MANA and CurrentEnergy < lastEnergyValue then
		lastEnergyTickTime = Now
		isWaiting = true
	elseif CurrentEnergy > lastEnergyValue or (Now >= lastEnergyTickTime + 2 and not isWaiting) then
		lastEnergyTickTime = Now
		isWaiting = nil
	end

	SetEnergyTickValue(self, Timer, isWaiting)

	lastEnergyValue = CurrentEnergy
end

local function Path(self, ...)
	return (self.EnergyTicker.Override or Update) (self, ...)
end

local function Enable(self, unit)
	local EnergyTicker = self.EnergyTicker
	local Power = self.Power

	if Power and EnergyTicker and (unit == "player") then
		EnergyTicker.__owner = self
		EnergyTicker.UpdateFrame = CreateFrame("Frame")

		if not EnergyTicker.Texture then
			EnergyTicker.Texture = self.EnergyTicker:CreateTexture(nil, 'OVERLAY', 8)
			EnergyTicker.Texture:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			EnergyTicker.Texture:SetSize(Power:GetHeight() + 10, Power:GetHeight() + 10)
			EnergyTicker.Texture:SetPoint("CENTER", Power, 0, 0)
			EnergyTicker.Texture:SetBlendMode("ADD")
		end
		EnergyTicker:SetAlpha(1)
		EnergyTicker.UpdateFrame:SetScript("OnUpdate", function() Path(self, unit) end)

		return true
	end
end

local function Disable(self)
	local EnergyTicker = self.EnergyTicker
	local Power = self.Power

	if Power and EnergyTicker then
		EnergyTicker:SetAlpha(0)
		EnergyTicker.UpdateFrame:SetScript("OnUpdate", nil)

		return false
	end
end

oUF:AddElement("EnergyTicker", Path, Enable, Disable)