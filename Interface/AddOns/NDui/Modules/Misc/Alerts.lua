local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local format, gsub, strsplit = string.format, string.gsub, string.split
local pairs, tonumber, wipe, select = pairs, tonumber, wipe, select
local GetInstanceInfo, GetAtlasInfo, PlaySound = GetInstanceInfo, GetAtlasInfo, PlaySound
local IsInRaid, IsInGroup, IsInInstance, IsInGuild = IsInRaid, IsInGroup, IsInInstance, IsInGuild
local UnitInRaid, UnitInParty, SendChatMessage = UnitInRaid, UnitInParty, SendChatMessage
local UnitName, Ambiguate, GetTime = UnitName, Ambiguate, GetTime
local GetSpellLink, GetSpellInfo = GetSpellLink, GetSpellInfo
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix

function M:AddAlerts()
	self:InterruptAlert()
	self:VersionCheck()
	self:PlacedItemAlert()
end

--[[
	闭上你的嘴！
	打断、偷取及驱散法术时的警报
]]
local function msgChannel()
	return IsInRaid() and "RAID" or "PARTY"
end

local infoType = {
	["SPELL_INTERRUPT"] = L["Interrupt"],
	["SPELL_STOLEN"] = L["Steal"],
	["SPELL_DISPEL"] = L["Dispel"],
	["SPELL_AURA_BROKEN_SPELL"] = L["BrokenSpell"],
}

local spellBlackList = {
	[122] = true,		-- 冰霜新星
	[1776] = true,		-- 凿击
	[1784] = true,		-- 潜行
	[5246] = true,		-- 破胆怒吼
	[8122] = true,		-- 心灵尖啸
}

local blackList = {}
for spellID in pairs(spellBlackList) do
	local name = GetSpellInfo(spellID)
	if name then
		blackList[name] = true
	end
end

function M:IsAllyPet(sourceFlags)
	if DB:IsMyPet(sourceFlags) or (not NDuiDB["Misc"]["OwnInterrupt"] and (sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags)) then
		return true
	end
end

function M:InterruptAlert_Update(...)
	if NDuiDB["Misc"]["AlertInInstance"] and (not IsInInstance()) then return end

	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, _, spellName, _, _, extraskillName, _, auraType = ...
	if not sourceGUID or sourceName == destName then return end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or M:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			if infoText == L["BrokenSpell"] then
				if not NDuiDB["Misc"]["BrokenSpell"] then return end
				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellName] then return end
				SendChatMessage(format(infoText, sourceName, extraskillName, destName, spellName), msgChannel())
			else
				if NDuiDB["Misc"]["OwnInterrupt"] and sourceName ~= DB.MyName and not M:IsAllyPet(sourceFlags) then return end
				SendChatMessage(format(infoText, sourceName, spellName, destName, extraskillName), msgChannel())
			end
		end
	end
end

function M:InterruptAlert_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	else
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

function M:InterruptAlert()
	if NDuiDB["Misc"]["Interrupt"] then
		self:InterruptAlert_CheckGroup()
		B:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
	else
		B:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

--[[
	NDui版本过期提示
]]
function M:VersionCheck_Compare(new, old)
	local new1, new2 = strsplit(".", new)
	new1, new2 = tonumber(new1), tonumber(new2)
	if new1 >= 2 then new1, new2 = 0, 0 end

	local old1, old2 = strsplit(".", old)
	old1, old2 = tonumber(old1), tonumber(old2)
	if old1 >= 2 then old1, old2 = 0, 0 end

	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

function M:VersionCheck_Create(text)
	local frame = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
	frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 20, 70)
	frame.Text:SetText(text)
	frame:Show()
end

local hasChecked
function M:VersionCheck_Initial()
	if not hasChecked then
		if M:VersionCheck_Compare(NDuiADB["DetectVersion"], DB.Version) == "IsNew" then
			local release = gsub(NDuiADB["DetectVersion"], "(%d+)$", "0")
			M:VersionCheck_Create(format(L["Outdated NDui"], release))
		end

		hasChecked = true
	end
end

local lastTime = 0
function M:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "NDuiVersionCheck" then return end
	if Ambiguate(author, "none") == DB.MyName then return end

	local status = M:VersionCheck_Compare(msg, NDuiADB["DetectVersion"])
	if status == "IsNew" then
		NDuiADB["DetectVersion"] = msg
	elseif status == "IsOld" then
		if GetTime() - lastTime > 10 then
			C_ChatInfo_SendAddonMessage("NDuiVersionCheck", NDuiADB["DetectVersion"], distType)
			lastTime = GetTime()
		end
	end

	M:VersionCheck_Initial()
end

local prevTime = 0
function M:VersionCheck_UpdateGroup()
	if not IsInGroup() or (GetTime()-prevTime < 30) then return end
	prevTime = GetTime()
	C_ChatInfo_SendAddonMessage("NDuiVersionCheck", DB.Version, msgChannel())
end

function M:VersionCheck()
	hasChecked = not NDuiADB["VersionCheck"]

	B:RegisterEvent("CHAT_MSG_ADDON", self.VersionCheck_Update)

	M:VersionCheck_Initial()
	C_ChatInfo_RegisterAddonMessagePrefix("NDuiVersionCheck")
	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("NDuiVersionCheck", DB.Version, "GUILD")
	end

	self:VersionCheck_UpdateGroup()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", self.VersionCheck_UpdateGroup)
end

--[[
	放大餐时叫一叫
]]
local lastTime = 0
local itemList = {
	[226241] = true,	-- 宁神圣典
	[256230] = true,	-- 静心圣典
	[185709] = true,	-- 焦糖鱼宴
	[259409] = true,	-- 海帆盛宴
	[259410] = true,	-- 船长盛宴
	[276972] = true,	-- 秘法药锅
	[286050] = true,	-- 鲜血大餐
	[265116] = true,	-- 工程战复
}

function M:ItemAlert_Update(unit, _, spellID)
	if not NDuiDB["Misc"]["PlacedItemAlert"] then return end

	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(format(L["Place item"], who, link or name), msgChannel())

		lastTime = GetTime()
	end
end

function M:ItemAlert_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.ItemAlert_Update)
	else
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.ItemAlert_Update)
	end
end

function M:PlacedItemAlert()
	self:ItemAlert_CheckGroup()
	B:RegisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
	B:RegisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
end