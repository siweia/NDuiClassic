local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")

function S:WhatsTraining()
	if not IsAddOnLoaded("WhatsTraining") then return end
	if not F then return end

	local done
	SpellBookFrame:HookScript("OnShow", function()
		if done then return end

		F.StripTextures(WhatsTrainingFrame)
		local bg = F.CreateBDFrame(WhatsTrainingFrameScrollBar, 1)
		bg:SetPoint("TOPLEFT", 20, 0)
		bg:SetPoint("BOTTOMRIGHT", 4, 0)
		F.ReskinScroll(WhatsTrainingFrameScrollBarScrollBar)
		B:GetModule("Tooltip").ReskinTooltip(WhatsTrainingTooltip)

		for i = 1, 22 do
			local bar = _G["WhatsTrainingFrameRow"..i.."Spell"]
			if bar and bar.icon then
				F.ReskinIcon(bar.icon)
			end
		end

		done = true
	end)
end

function S:ResetRecount()
	Recount:RestoreMainWindowPosition(797, -405, 320, 220)

	Recount.db.profile.Locked = true
	Recount:LockWindows(true)

	Recount.db.profile.MainWindowHeight = 320
	Recount.db.profile.MainWindowWidth = 220
	Recount:ResizeMainWindow()

	Recount.db.profile.MainWindow.RowHeight = 18
	Recount:BarsChanged()

	Recount.db.profile.BarTexture = "normTex"
	Recount.db.profile.Font = DEFAULT
	Recount:UpdateBarTextures()

	NDuiADB["ResetRecount"] = false
end

function S:RecountSkin()
	if not IsAddOnLoaded("Recount") then return end

	local frame = Recount_MainWindow
	B.StripTextures(frame)
	local bg = B.CreateBG(frame)
	bg:SetPoint("TOPLEFT", 0, -10)
	B.CreateBD(bg)
	B.CreateSD(bg)
	B.CreateTex(bg)
	frame.bg = bg

	local open, close = S:CreateToggle(frame)
	open:HookScript("OnClick", function()
		Recount.MainWindow:Show()
		Recount:RefreshMainWindow()
	end)
	close:HookScript("OnClick", function()
		Recount.MainWindow:Hide()
	end)

	if NDuiADB["ResetRecount"] then S:ResetRecount() end
	hooksecurefunc(Recount, "ResetPositions", S.ResetRecount)

	if F then
		F.ReskinArrow(frame.LeftButton, "left")
		F.ReskinArrow(frame.RightButton, "right")
		F.ReskinClose(frame.CloseButton, "TOPRIGHT", frame.bg, "TOPRIGHT", -2, -2)
	end
end