local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	F.ReskinPortraitFrame(WorldMapFrame, 7, 0, -7, 25)
	F.ReskinDropDown(WorldMapContinentDropDown)
	F.ReskinDropDown(WorldMapZoneDropDown)
	F.Reskin(WorldMapZoomOutButton)

	C_Timer.After(3, function()
		if CodexQuestMapDropdown then
			F.ReskinDropDown(CodexQuestMapDropdown)
			CodexQuestMapDropdownButton.SetWidth = F.dummy
		end
		if Questie_Toggle then
			F.Reskin(Questie_Toggle)
		end
	end)
end)