local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 术士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 5697, UnitID = "player"},		-- 无尽呼吸
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 710, UnitID = "target", Caster = "player"},		-- 放逐术
		{AuraID = 6358, UnitID = "target", Caster = "pet"},			-- 魅惑
		{AuraID = 6789, UnitID = "target", Caster = "player"},		-- 死亡缠绕
		{AuraID = 5484, UnitID = "target", Caster = "player"},		-- 恐惧嚎叫
		{AuraID = 17877, UnitID = "target", Caster = "player"},		-- 暗影灼烧
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--{AuraID = 89751, UnitID = "pet"},		-- 魔刃风暴
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("WARLOCK", list)