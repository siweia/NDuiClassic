local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local _G = getfenv(0)
local tinsert, pairs, type = table.insert, pairs, type
local buttonList = {}

function S:MicroButton_SetupTexture(icon, texcoord, texture)
	local r, g, b = DB.r, DB.g, DB.b
	if not NDuiDB["Skins"]["ClassLine"] then r, g, b = 0, 0, 0 end

	icon:SetAllPoints()
	icon:SetTexture(DB.MicroTex..texture)
	icon:SetTexCoord(unpack(texcoord))
	icon:SetVertexColor(r, g, b)
end

function S:MicroButton_Create(parent, data)
	local texture, texcoord, tip, func = unpack(data)

	local bu = CreateFrame("Button", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(22, 22)
	bu:SetFrameStrata("BACKGROUND")
	bu:SetScript("OnClick", func)
	B.AddTooltip(bu, "ANCHOR_TOP", tip)

	local icon = bu:CreateTexture(nil, "ARTWORK")
	S:MicroButton_SetupTexture(icon, texcoord, texture)

	bu:SetHighlightTexture(DB.MicroTex..texture)
	local highlight = bu:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexCoord(unpack(texcoord))
	if NDuiDB["Skins"]["ClassLine"] then
		highlight:SetVertexColor(r, g, b)
	else
		highlight:SetVertexColor(1, 1, 1)
	end
end

function S:MicroMenu()
	if not NDuiDB["Skins"]["MicroMenu"] then return end

	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(238, 22)
	B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)

	-- Generate Buttons
	local buttonInfo = {
		{"player", {51/256, 141/256, 86/256, 173/256}, MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0"), function() ToggleFrame(CharacterFrame) end},
		{"spellbook", {83/256, 173/256, 86/256, 173/256}, MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), function() ToggleFrame(SpellBookFrame) end},
		{"talents", {83/256, 173/256, 86/256, 173/256}, MicroButtonTooltipText(TALENTS, "TOGGLETALENTS"), function()
			if UnitLevel("player") < SHOW_SPEC_LEVEL then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL))
			else
				ToggleTalentFrame()
			end
		end},
		{"quests", {83/256, 173/256, 80/256, 167/256}, MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), ToggleQuestLog},
		{"guild", {83/256, 173/256, 80/256, 167/256}, MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL"), function() ToggleFrame(FriendsFrame) end},
		{"pets", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP"), ToggleWorldMap},
		{"help", {83/256, 173/256, 80/256, 170/256}, MicroButtonTooltipText(HELP_BUTTON, "TOGGLEHELP"), function() ToggleFrame(HelpFrame) end},
		{"settings", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), function() ToggleFrame(GameMenuFrame) PlaySound(SOUNDKIT.IG_MINIMAP_OPEN) end},
		{"bags", {47/256, 137/256, 83/256, 173/256}, MicroButtonTooltipText(BAGSLOT, "OPENALLBAGS"), ToggleAllBags},
	}
	for _, info in pairs(buttonInfo) do
		S:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", 5, 0)
		end
	end

	-- Taint Fix
	ToggleFrame(SpellBookFrame)
	ToggleFrame(SpellBookFrame)
end