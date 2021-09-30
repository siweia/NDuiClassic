local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 534 -- 海加尔山之战

module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- 荒芜诅咒