local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 牧师的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 586, UnitID = "player"},		-- 渐隐术
		{AuraID = 17, UnitID = "player", Caster = "player"},		-- 真言术：盾
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 139, UnitID = "target", Caster = "player"},		-- 恢复
		{AuraID = 589, UnitID = "target", Caster = "player"},		-- 暗言术:痛
		{AuraID = 8122, UnitID = "target", Caster = "player"},		-- 心灵尖啸
		{AuraID = 15487, UnitID = "target", Caster = "player"},		-- 沉默
		{AuraID = 17, UnitID = "target", Caster = "player", Value = true},		-- 真言术：盾
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 10060, UnitID = "player"},	-- 能量灌注
		{AuraID = 27827, UnitID = "player"},	-- 救赎之魂
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("PRIEST", list)