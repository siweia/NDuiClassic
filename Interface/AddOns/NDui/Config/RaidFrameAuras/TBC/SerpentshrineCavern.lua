local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 548 -- 毒蛇神殿

module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- 荒芜诅咒