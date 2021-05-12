local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local wipe, gmatch, tinsert, ipairs, pairs = wipe, gmatch, tinsert, ipairs, pairs
local tonumber, tostring = tonumber, tostring
local cr, cg, cb = DB.r, DB.g, DB.b

local function SetCharacterStats(statsTable, category)
    if category == "PLAYERSTAT_BASE_STATS" then
        PaperDollFrame_SetStat(statsTable[1], 1)
        PaperDollFrame_SetStat(statsTable[2], 2)
        PaperDollFrame_SetStat(statsTable[3], 3)
        PaperDollFrame_SetStat(statsTable[4], 4)
        PaperDollFrame_SetStat(statsTable[5], 5)
        PaperDollFrame_SetArmor(statsTable[6])
    elseif category == "PLAYERSTAT_DEFENSES" then
        PaperDollFrame_SetArmor(statsTable[1])
        PaperDollFrame_SetDefense(statsTable[2])
        PaperDollFrame_SetDodge(statsTable[3])
        PaperDollFrame_SetParry(statsTable[4])
        PaperDollFrame_SetBlock(statsTable[5])
        PaperDollFrame_SetResilience(statsTable[6])
    elseif category == "PLAYERSTAT_MELEE_COMBAT" then
        PaperDollFrame_SetDamage(statsTable[1])
        statsTable[1]:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
        PaperDollFrame_SetAttackSpeed(statsTable[2])
        PaperDollFrame_SetAttackPower(statsTable[3])
        PaperDollFrame_SetRating(statsTable[4], CR_HIT_MELEE)
        PaperDollFrame_SetMeleeCritChance(statsTable[5])
        PaperDollFrame_SetExpertise(statsTable[6])
    elseif category == "PLAYERSTAT_SPELL_COMBAT" then
        PaperDollFrame_SetSpellBonusDamage(statsTable[1])
        statsTable[1]:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
        PaperDollFrame_SetSpellBonusHealing(statsTable[2])
        PaperDollFrame_SetRating(statsTable[3], CR_HIT_SPELL)
        PaperDollFrame_SetSpellCritChance(statsTable[4])
        statsTable[4]:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
        PaperDollFrame_SetSpellHaste(statsTable[5])
        PaperDollFrame_SetManaRegen(statsTable[6])
    elseif category == "PLAYERSTAT_RANGED_COMBAT" then
        PaperDollFrame_SetRangedDamage(statsTable[1])
        statsTable[1]:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
        PaperDollFrame_SetRangedAttackSpeed(statsTable[2])
        PaperDollFrame_SetRangedAttackPower(statsTable[3])
        PaperDollFrame_SetRating(statsTable[4], CR_HIT_RANGED)
        PaperDollFrame_SetRangedCritChance(statsTable[5])
    end
end

local orderList = {}
local function BuildListFromValue()
    wipe(orderList)

    for number in gmatch(C.db["Misc"]["StatOrder"], "%d") do
        tinsert(orderList, tonumber(number))
    end
end

local categoryFrames = {}
local framesToSort = {}
local function UpdateCategoriesOrder()
    wipe(framesToSort)

    for order, index in ipairs(orderList) do
        tinsert(framesToSort, categoryFrames[index])
    end
end

local function UpdateCategoriesAnchor()
    UpdateCategoriesOrder()

    local prev
    for _, frame in pairs(framesToSort) do
        if not prev then
            frame:SetPoint("TOP", 0, -35)
        else
            frame:SetPoint("TOP", prev, "BOTTOM")
        end
        prev = frame
    end
end

local function BuildValueFromList()
    local str = ""
    for _, index in ipairs(orderList) do
        str = str..tostring(index)
    end
    C.db["Misc"]["StatOrder"] = str

    UpdateCategoriesAnchor()
end

local function Arrow_GoUp(bu)
    local frameIndex = bu.__owner.index

    BuildListFromValue()

    for order, index in pairs(orderList) do
        if index == frameIndex then
            if order > 1 then
                local oldIndex = orderList[order-1]
                orderList[order-1] = frameIndex
                orderList[order] = oldIndex

                BuildValueFromList()
            end
            break
        end
    end
end

local function Arrow_GoDown(bu)
    local frameIndex = bu.__owner.index

    BuildListFromValue()

    for order, index in pairs(orderList) do
        if index == frameIndex then
            if order < 5 then
                local oldIndex = orderList[order+1]
                orderList[order+1] = frameIndex
                orderList[order] = oldIndex

                BuildValueFromList()
            end
            break
        end
    end
end

local function CreateStatRow(parent, index)
    local frame = CreateFrame("Frame", "$parentRow"..index, parent, "StatFrameTemplate")
    frame:SetWidth(180)
    frame:SetPoint("TOP", parent.header, "BOTTOM", 0, -2 - (index-1)*16)
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAtlas("UI-Character-Info-Line-Bounce", true)
    background:SetAlpha(.3)
    background:SetPoint("CENTER")
    background:SetShown(index%2 == 0)

    return frame
end

local function CreateHeaderArrow(parent, direct, func)
    local onLeft = direct == "LEFT"
    local xOffset = onLeft and 10 or -10
    local arrowDirec = onLeft and "up" or "down"

    local bu = CreateFrame("Button", nil, parent)
    bu:SetPoint(direct, parent.header, xOffset, 0)
    B.ReskinArrow(bu, arrowDirec)
    bu:SetSize(18, 18)
    bu.__owner = parent
    bu:SetScript("OnClick", func)
end

local function CreateStatHeader(parent, index, category)
    local maxLines = index == 5 and 5 or 6
    local frame = CreateFrame("Frame", "NDuiStatCategory"..index, parent)
    frame:SetWidth(200)
    frame:SetHeight(42 + maxLines*16)
    frame.index = index
    tinsert(categoryFrames, frame)

    local header = CreateFrame("Frame", "$parentHeader", frame, "CharacterStatFrameCategoryTemplate")
    header:SetPoint("TOP")
    header.Background:Hide()
    header.Title:SetText(_G[category])
    header.Title:SetTextColor(cr, cg, cb)
    frame.header = header

    CreateHeaderArrow(frame, "LEFT", Arrow_GoUp)
    CreateHeaderArrow(frame, "RIGHT", Arrow_GoDown)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(180, C.mult)
    line:SetPoint("BOTTOM", header, 0, 5)
    line:SetColorTexture(1, 1, 1, .25)

    local statsTable = {}
    for i = 1, maxLines do
        statsTable[i] = CreateStatRow(frame, i)
    end
    SetCharacterStats(statsTable, category)
    frame.category = category
    frame.statsTable = statsTable

    return frame
end

local function ToggleMagicRes()
    if C.db["Misc"]["ExpandStat"] then
        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint("TOPLEFT", M.StatPanel.child, 25, -5)
        CharacterResistanceFrame:SetParent(M.StatPanel)

        for i = 1, 5 do
            local bu = _G["MagicResFrame"..i]
            if i > 1 then
                bu:ClearAllPoints()
                bu:SetPoint("LEFT", _G["MagicResFrame"..(i-1)], "RIGHT", 5, 0)
            end
        end
    else
        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint("TOPRIGHT", PaperDollFrame, "TOPLEFT", 297, -77)
        CharacterResistanceFrame:SetParent(PaperDollFrame)

        for i = 1, 5 do
            local bu = _G["MagicResFrame"..i]
            if i > 1 then
                bu:ClearAllPoints()
                bu:SetPoint("TOP", _G["MagicResFrame"..(i-1)], "BOTTOM")
            end
        end
    end
end

local function UpdateStats()
    if not (M.StatPanel and M.StatPanel:IsShown()) then return end

    for _, frame in pairs(categoryFrames) do
        SetCharacterStats(frame.statsTable, frame.category)
    end
end

local function ToggleStatPanel(texture)
    if C.db["Misc"]["ExpandStat"] then
        B.SetupArrow(texture, "down")
        CharacterAttributesFrame:Hide()
        M.StatPanel:Show()
    else
        B.SetupArrow(texture, "right")
        CharacterAttributesFrame:Show()
        M.StatPanel:Hide()
    end
    ToggleMagicRes()
end

function M:CharacterStatePanel()
	local statPanel = CreateFrame("Frame", "NDuiStatePanel", PaperDollFrame)
	statPanel:SetSize(200, 422)
	statPanel:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -32, -15-C.mult)
	B.SetBD(statPanel)
    M.StatPanel = statPanel

	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = B.Dummy
	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
    statPanel.child = stat
	scrollFrame:SetScrollChild(stat)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scrollBar = self.ScrollBar
		local step = delta*25
		if IsShiftKeyDown() then
			step = step*6
		end
		scrollBar:SetValue(scrollBar:GetValue() - step)
	end)

	local categories = {
		"PLAYERSTAT_BASE_STATS",
		"PLAYERSTAT_DEFENSES",
		"PLAYERSTAT_MELEE_COMBAT",
		"PLAYERSTAT_SPELL_COMBAT",
		"PLAYERSTAT_RANGED_COMBAT",
	}
	for index, category in pairs(categories) do
		CreateStatHeader(stat, index, category)
	end

    -- Init
    BuildListFromValue()
    BuildValueFromList()

    -- Update data
	hooksecurefunc("ToggleCharacter", UpdateStats)
	PaperDollFrame:HookScript("OnEvent", UpdateStats)

	-- Expand button
	local bu = CreateFrame("Button", nil, PaperDollFrame)
	bu:SetPoint("RIGHT", CharacterFrameCloseButton, "LEFT", -3, 0)
	B.ReskinArrow(bu, "right")

	bu:SetScript("OnClick", function(self)
		C.db["Misc"]["ExpandStat"] = not C.db["Misc"]["ExpandStat"]
		ToggleStatPanel(self.__texture)
	end)

	ToggleStatPanel(bu.__texture)
end

M:RegisterMisc("StatPanel", M.CharacterStatePanel)