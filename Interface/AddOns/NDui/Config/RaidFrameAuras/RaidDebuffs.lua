local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

--[[
	RaidFrame debuffs
	"raid" spells only available in Raids
	"other" spells won't work in Raids
	[spellID] = priority
	priority limit in 1-6
]]
local list = {
	["raid"] = {
		[1459] = 2,		-- 奥术智慧
	},
	["other"] = {
		[13704] = 2,	-- 心灵尖啸
	},
}

module:AddRaidDebuffs(list)