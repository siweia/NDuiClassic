local _, ns = ...
local B, C, L, DB = unpack(ns)

local unpack = unpack
local GetTime, UnitIsUnit = GetTime, UnitIsUnit

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}
local NotInterruptColor = {r=1, g=.5, b=.5}

local channelingTicks = { -- ElvUI data
	--First Aid
	[23567] = 8, --Warsong Gulch Runecloth Bandage
	[23696] = 8, --Alterac Heavy Runecloth Bandage
	[24414] = 8, --Arathi Basin Runecloth Bandage
	[18610] = 8, --Heavy Runecloth Bandage
	[18608] = 8, --Runecloth Bandage
	[10839] = 8, --Heavy Mageweave Bandage
	[10838] = 8, --Mageweave Bandage
	[7927] = 8, --Heavy Silk Bandage
	[7926] = 8, --Silk Bandage
	[3268] = 7, --Heavy Wool Bandage
	[3267] = 7, --Wool Bandage
	[1159] = 6, --Heavy Linen Bandage
	[746] = 6, --Linen Bandage
	-- Warlock
	[1120] = 5, -- Drain Soul(Rank 1)
	[8288] = 5, -- Drain Soul(Rank 2)
	[8289] = 5, -- Drain Soul(Rank 3)
	[11675] = 5, -- Drain Soul(Rank 4)
	[755] = 10, -- Health Funnel(Rank 1)
	[3698] = 10, -- Health Funnel(Rank 2)
	[3699] = 10, -- Health Funnel(Rank 3)
	[3700] = 10, -- Health Funnel(Rank 4)
	[11693] = 10, -- Health Funnel(Rank 5)
	[11694] = 10, -- Health Funnel(Rank 6)
	[11695] = 10, -- Health Funnel(Rank 7)
	[689] = 5, -- Drain Life(Rank 1)
	[699] = 5, -- Drain Life(Rank 2)
	[709] = 5, -- Drain Life(Rank 3)
	[7651] = 5, -- Drain Life(Rank 4)
	[11699] = 5, -- Drain Life(Rank 5)
	[11700] = 5, -- Drain Life(Rank 6)
	[5740] =  4, --Rain of Fire(Rank 1)
	[6219] =  4, --Rain of Fire(Rank 2)
	[11677] =  4, --Rain of Fire(Rank 3)
	[11678] =  4, --Rain of Fire(Rank 4)
	[1949] = 15, --Hellfire(Rank 1)
	[11683] = 15, --Hellfire(Rank 2)
	[11684] = 15, --Hellfire(Rank 3)
	[5138] = 5, --Drain Mana(Rank 1)
	[6226] = 5, --Drain Mana(Rank 2)
	[11703] = 5, --Drain Mana(Rank 3)
	[11704] = 5, --Drain Mana(Rank 4)
	-- Priest
	[15407] = 3, -- Mind Flay(Rank 1)
	[17311] = 3, -- Mind Flay(Rank 2)
	[17312] = 3, -- Mind Flay(Rank 3)
	[17313] = 3, -- Mind Flay(Rank 4)
	[17314] = 3, -- Mind Flay(Rank 5)
	[18807] = 3, -- Mind Flay(Rank 6)
	-- Mage
	[10] = 8, --Blizzard(Rank 1)
	[6141] = 8, --Blizzard(Rank 2)
	[8427] = 8, --Blizzard(Rank 3)
	[10185] = 8, --Blizzard(Rank 4)
	[10186] = 8, --Blizzard(Rank 5)
	[10187] = 8, --Blizzard(Rank 6)
	[5143] = 3, -- Arcane Missiles(Rank 1)
	[5144] = 4, -- Arcane Missiles(Rank 2)
	[5145] = 5, -- Arcane Missiles(Rank 3)
	[8416] = 5, -- Arcane Missiles(Rank 4)
	[8417] = 5, -- Arcane Missiles(Rank 5)
	[10211] = 5, -- Arcane Missiles(Rank 6)
	[10212] = 5, -- Arcane Missiles(Rank 7)
	[12051] = 4, -- Evocation
	--Druid
	[740] = 5, -- Tranquility(Rank 1)
	[8918] = 5, --Tranquility(Rank 2)
	[9862] = 5, --Tranquility(Rank 3)
	[9863] = 5, --Tranquility(Rank 4)
	[16914] = 10, --Hurricane(Rank 1)
	[17401] = 10, --Hurricane(Rank 2)
	[17402] = 10, --Hurricane(Rank 3)
	--Hunter
	[1510] = 6, --Volley(Rank 1)
	[14294] = 6, --Volley(Rank 2)
	[14295] = 6, --Volley(Rank 3)
	[136] = 5, --Mend Pet(Rank 1)
	[3111] = 5, --Mend Pet(Rank 2)
	[3661] = 5, --Mend Pet(Rank 3)
	[3662] = 5, --Mend Pet(Rank 4)
	[13542] = 5, --Mend Pet(Rank 5)
	[13543] = 5, --Mend Pet(Rank 6)
	[13544] = 5, --Mend Pet(Rank 7)
}

local ticks = {}
local function updateCastBarTicks(bar, numTicks)
	if numTicks and numTicks > 0 then
		local delta = bar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not ticks[i] then
				ticks[i] = bar:CreateTexture(nil, "OVERLAY")
				ticks[i]:SetTexture(DB.normTex)
				ticks[i]:SetVertexColor(0, 0, 0, .7)
				ticks[i]:SetWidth(C.mult)
				ticks[i]:SetHeight(bar:GetHeight())
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", bar, "LEFT", delta * i, 0 )
			ticks[i]:Show()
		end
	else
		for _, tick in pairs(ticks) do
			tick:Hide()
		end
	end
end

local function isPlayerCasting()
	local bar = oUF_Castbarplayer
	if not bar then return end
	if bar.casting or bar.channeling then
		return true
	end
end

function B:FixTargetCastbarUpdate()
	if UnitIsUnit("target", "player") and not isPlayerCasting() then
		self.casting = nil
		self.channeling = nil
		self.Text:SetText(INTERRUPTED)
		self.holdTime = 0
	end
end

function B:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling then
		B.FixTargetCastbarUpdate(self)

		local decimal = self.decimal

		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal.." | |cffff0000"..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.max)
				if self.Lag and self.SafeZone and self.SafeZone.timeDiff and self.SafeZone.timeDiff ~= 0 then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ | ∞")
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - .02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function B:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then return end
	element.SafeZone.sendTime = GetTime()
	element.SafeZone.castSent = true
end

function B:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()
	local color = NDuiDB["UFs"]["CastingColor"]
	self:SetStatusBarColor(color.r, color.g, color.b)

	if unit == "vehicle" then
		if self.SafeZone then self.SafeZone:Hide() end
		if self.Lag then self.Lag:Hide() end
	elseif unit == "player" then
		local safeZone = self.SafeZone
		if not safeZone then return end

		safeZone.timeDiff = 0
		if safeZone.castSent then
			safeZone.timeDiff = GetTime() - safeZone.sendTime
			safeZone.timeDiff = safeZone.timeDiff > self.max and self.max or safeZone.timeDiff
			safeZone:SetWidth(self:GetWidth() * (safeZone.timeDiff + .001) / self.max)
			safeZone:Show()
			safeZone.castSent = false
		end

		local numTicks = 0
		if self.channeling then
			numTicks = channelingTicks[self.spellID] or 0
		end
		updateCastBarTicks(self, numTicks)
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = NotInterruptColor
		self:SetStatusBarColor(color.r, color.g, color.b)
	end

	-- Fix for empty icon
	if self.Icon then
		local texture = self.Icon:GetTexture()
		if not texture or texture == 136235 then
			self.Icon:SetTexture(136243)
		end
	end
end

function B:PostUpdateInterruptible(unit)
	local color = NDuiDB["UFs"]["CastingColor"]
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = NotInterruptColor
	end
	self:SetStatusBarColor(color.r, color.g, color.b)
end

function B:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(CastbarCompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.max or 1)
	self:Show()
end

function B:PostChannelStop()
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

function B:PostCastFailed()
	self:SetStatusBarColor(unpack(CastbarFailColor))
	self:SetValue(self.max or 1)
	self.fadeOut = true
	self:Show()
end