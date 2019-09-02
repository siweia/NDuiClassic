local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	TaxiFramePortrait = TaxiPortrait
	TaxiFrameCloseButton = TaxiCloseButton
	F.ReskinPortraitFrame(TaxiFrame, 17, -8, -45, 82)
end)