local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("AurasTable")
local pairs, next, format, wipe = pairs, next, string.format, wipe

-- AuraWatch
local AuraWatchList = {}
local groups = {
	-- groups name = direction, interval, mode, iconsize, position, barwidth
	["Player Aura"] = {"LEFT", 5, "ICON", 22, C.Auras.PlayerAuraPos},
	["Target Aura"] = {"RIGHT", 5, "ICON", 36, C.Auras.TargetAuraPos},
	["Special Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.SpecialPos},
	["Focus Aura"] = {"RIGHT", 5, "ICON", 35, C.Auras.FocusPos},
	["Spell Cooldown"] = {"UP", 5, "BAR", 18, C.Auras.CDPos, 150},
	["Enchant Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.EnchantPos},
	["Raid Buff"] = {"LEFT", 5, "ICON", 42, C.Auras.RaidBuffPos},
	["Raid Debuff"] = {"RIGHT", 5, "ICON", 42, C.Auras.RaidDebuffPos},
	["Warning"] = {"RIGHT", 5, "ICON", 42, C.Auras.WarningPos},
	["InternalCD"] = {"UP", 5, "BAR", 18, C.Auras.InternalPos, 150},
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					wipe(v)
					if DB.isDeveloper then
						print(format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= DB.MyClass then return end
	if not AuraWatchList[class] then AuraWatchList[class] = {} end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		tinsert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v)
		})
	end
end

-- RaidFrame spells
local RaidBuffs = {}
function module:AddClassSpells(list)
	for class, value in pairs(list) do
		if class == "ALL" then
			if not RaidBuffs[class] then RaidBuffs[class] = {} end
			for spellID in pairs(value) do
				local name = GetSpellInfo(spellID)
				if name then
					RaidBuffs[class][name] = true
				end
			end
		end
	end
end

-- RaidFrame debuffs
local RaidDebuffs = {}
function module:AddRaidDebuffs(list)
	for instType, value in pairs(list) do
		for spellID, prio in pairs(value) do
			if not RaidDebuffs[instType] then RaidDebuffs[instType] = {} end
			if prio > 6 then prio = 6 end
			RaidDebuffs[instType][spellID] = prio
		end
	end
end

function module:BuildNameListFromID()
	if not C.CornerBuffsByName then C.CornerBuffsByName = {} end
	wipe(C.CornerBuffsByName)

	local myCornerBuffs = NDuiADB["CornerBuffs"][DB.MyClass]
	if not myCornerBuffs then return end

	for spellID, value in pairs(myCornerBuffs) do
		local name = GetSpellInfo(spellID)
		if name then
			C.CornerBuffsByName[name] = value
		end
	end
end

function module:CheckMajorSpells()
	for spellID in pairs(C.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			if NDuiADB["MajorSpells"][spellID] then
				NDuiADB["MajorSpells"][spellID] = nil
			end
		else
			if DB.isDeveloper then print("Invalid cornerspell ID: "..spellID) end
		end
	end

	for spellID, value in pairs(NDuiADB["MajorSpells"]) do
		if value == false and C.MajorSpells[spellID] == nil then
			NDuiADB["MajorSpells"][spellID] = nil
		end
	end
end

function module:OnLogin()
	-- Cleanup data
	if next(NDuiADB["RaidDebuffs"]) and not NDuiADB["RaidDebuffs"]["raid"] and not NDuiADB["RaidDebuffs"]["other"] then
		wipe(NDuiADB["RaidDebuffs"])
	end
	for instType, value in pairs(RaidDebuffs) do
		for spellID, prio in pairs(value) do
			if NDuiADB["RaidDebuffs"][instType] and NDuiADB["RaidDebuffs"][instType][spellID] and NDuiADB["RaidDebuffs"][instType][spellID] == prio then
				NDuiADB["RaidDebuffs"][instType][spellID] = nil
			end
		end
	end

	C.AuraWatchList = AuraWatchList
	C.RaidBuffs = RaidBuffs
	C.RaidDebuffs = RaidDebuffs

	if not NDuiADB["CornerBuffs"][DB.MyClass] then NDuiADB["CornerBuffs"][DB.MyClass] = {} end
	if not next(NDuiADB["CornerBuffs"][DB.MyClass]) then
		B.CopyTable(C.CornerBuffs[DB.MyClass], NDuiADB["CornerBuffs"][DB.MyClass])
	end
	module:BuildNameListFromID()

	module:CheckMajorSpells()
end