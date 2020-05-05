local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	GameMenuFrameHeader:SetAlpha(0)
	GameMenuFrameHeader:ClearAllPoints()
	GameMenuFrameHeader:SetPoint("TOP", GameMenuFrame, 0, 7)
	B.CreateBD(GameMenuFrame)
	B.CreateSD(GameMenuFrame)
	--GameMenuFrame.Border:Hide()

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue
	}

	for _, button in next, buttons do
		B.Reskin(button)
	end
end)