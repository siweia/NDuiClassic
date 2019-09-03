local _, ns = ...
local B, C, L, DB, F, T = unpack(ns)
local S = B:GetModule("Skins")

function S:ReskinQuestLogEx()
	if not NDuiDB["Skins"]["QuestLogEx"] then return end
	if not F then return end
	if not IsAddOnLoaded("QuestLogEx") then return end

	B.CreateMF(QuestLogExFrame)
	local BG = F.ReskinPortraitFrame(QuestLogExFrame, 10, -5, -30, 0)
	hooksecurefunc(QuestLogEx, "ToggleExtended", function()
		if QuestLogExFrameDescription:IsVisible() then
			BG:SetPoint("BOTTOMRIGHT", QuestLogExFrameDescription, -25, 0)
		else
			BG:SetPoint("BOTTOMRIGHT", QuestLogExFrame, -30, 0)
		end
	end)

	F.StripTextures(QuestLogExFrameDescription)
	F.ReskinClose(QuestLogExDetailCloseButton, "TOPRIGHT", QuestLogExFrameDescription, -30, -10)
	F.ReskinArrow(QuestLogExFrameMaximizeButton, "right")
	QuestLogExFrameMaximizeButton:ClearAllPoints()
	QuestLogExFrameMaximizeButton:SetPoint("RIGHT", QuestLogExFrameCloseButton, "LEFT", -2, 0)
	F.ReskinArrow(QuestLogExDetailMinimizeButton, "left")
	QuestLogExDetailMinimizeButton:ClearAllPoints()
	QuestLogExDetailMinimizeButton:SetPoint("RIGHT", QuestLogExDetailCloseButton, "LEFT", -2, 0)

	F.ReskinScroll(QuestLogExDetailScrollFrameScrollBar)
	F.Reskin(QuestLogExFrameAbandonButton)
	F.Reskin(QuestLogExFramePushQuestButton)
	F.Reskin(QuestLogExFrameExitButton)
	F.Reskin(QuestLogExDetailExitButton)
	F.ReskinExpandOrCollapse(QuestLogExCollapseAllButton)
	QuestLogExCollapseAllButton:DisableDrawLayer("BACKGROUND")
	for i = 1, 27 do
		local title = _G["QuestLogExTitle"..i]
		F.ReskinExpandOrCollapse(title)
	end

	for i = 1, 10 do
		local icon = _G["QuestLogExItem"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(icon)
		local nameFrame = _G["QuestLogExItem"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = F.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end

	-- Text
	QuestLogExQuestTitle:SetTextColor(1, .8, 0)
	QuestLogExDescriptionTitle:SetTextColor(1, .8, 0)
	for i = 1, 10 do
		local text = _G["QuestLogExObjective"..i]
		text:SetTextColor(.7, .7, .7)
		text.SetTextColor = F.dummy
	end
	QuestLogExRewardTitleText:SetTextColor(1, .8, 0)
	QuestLogExRewardTitleText.SetTextColor = F.dummy
	QuestLogExItemChooseText:SetTextColor(1, 1, 1)
	QuestLogExItemChooseText.SetTextColor = F.dummy
end