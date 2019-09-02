local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 萨满的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 546, UnitID = "player"},		-- 水上行走
	},
	["Target Aura"] = {		-- 目标光环组
		--{AuraID = 61295, UnitID = "target", Caster = "player"},		-- 激流
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--{AuraID = 73920, UnitID = "player"},	-- 治疗之雨
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 20608},	-- 复生
	},
}

module:AddNewAuraWatch("SHAMAN", list)