local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	B.ReskinPortraitFrame(WorldMapFrame, 7, 0, -7, 25)
	B.ReskinDropDown(WorldMapContinentDropDown)
	B.ReskinDropDown(WorldMapZoneDropDown)
	B.Reskin(WorldMapZoomOutButton)

	C_Timer.After(3, function()
		if CodexQuestMapDropdown then
			B.ReskinDropDown(CodexQuestMapDropdown)
			CodexQuestMapDropdownButton.SetWidth = B.Dummy
		end
		if Questie_Toggle then
			B.Reskin(Questie_Toggle)
		end
	end)
end)