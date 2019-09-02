local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 德鲁伊的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 5215, UnitID = "player"},		-- 潜行
		{AuraID = 1850, UnitID = "player"},		-- 急奔
		{AuraID = 774, UnitID = "player", Caster = "player"},		-- 回春术
		{AuraID = 8936, UnitID = "player", Caster = "player"},		-- 愈合
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 99, UnitID = "target", Caster = "player"},		-- 夺魂咆哮
		{AuraID = 339, UnitID = "target", Caster = "player"},		-- 纠缠根须
		{AuraID = 774, UnitID = "target", Caster = "player"},		-- 回春术
		{AuraID = 1079, UnitID = "target", Caster = "player"},		-- 割裂
		{AuraID = 5211, UnitID = "target", Caster = "player"},		-- 蛮力猛击
		{AuraID = 6795, UnitID = "target", Caster = "player"},		-- 低吼
		{AuraID = 8936, UnitID = "target", Caster = "player"},		-- 愈合
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 5217, UnitID = "player"},		-- 猛虎之怒
		{AuraID = 22842, UnitID = "player"},	-- 狂暴回复
		{AuraID = 22812, UnitID = "player"},	-- 树皮术
		{AuraID = 16870, UnitID = "player"},	-- 节能施法
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("DRUID", list)