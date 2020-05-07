local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.SetBD(TutorialFrame)

	TutorialFrame:DisableDrawLayer("BORDER")
	B.Reskin(TutorialFrameOkayButton, true)
	TutorialFrameOkayButton:ClearAllPoints()
	TutorialFrameOkayButton:SetPoint("BOTTOMLEFT", TutorialFrameNextButton, "BOTTOMRIGHT", 10, 0)

	-- because gradient alpha and OnUpdate doesn't work for some reason...

	if select(14, TutorialFrameOkayButton:GetRegions()) then
		select(14, TutorialFrameOkayButton:GetRegions()):Hide()
	end
	TutorialFrameOkayButton:SetBackdropColor(0, 0, 0, .25)
end)