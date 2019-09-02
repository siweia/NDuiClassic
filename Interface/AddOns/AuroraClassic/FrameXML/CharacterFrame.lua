local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)

	for i = 1, 4 do
		F.ReskinTab(_G["CharacterFrameTab"..i])
	end
end)