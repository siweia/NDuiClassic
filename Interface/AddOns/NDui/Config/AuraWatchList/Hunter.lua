local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 猎人的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 136, UnitID = "pet"},			-- 治疗宠物
		{AuraID = 19577, UnitID = "pet"},		-- 胁迫
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 3355, UnitID = "target", Caster = "player"},		-- 冰冻陷阱
		{AuraID = 5116, UnitID = "target", Caster = "player"},		-- 震荡射击
		{AuraID = 19386, UnitID = "target", Caster = "player"},		-- 翼龙钉刺
		{AuraID = 24394, UnitID = "target", Caster = "pet"},		-- 胁迫
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 19574, UnitID = "player"},	-- 狂野怒火
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("HUNTER", list)