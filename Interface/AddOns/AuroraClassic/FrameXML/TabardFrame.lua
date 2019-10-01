local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(TabardFrame)
	F.CreateBD(TabardFrameCostFrame, .25)
	F.Reskin(TabardFrameAcceptButton)
	F.Reskin(TabardFrameCancelButton)
	F.ReskinRotationButtons("TabardCharacterModel")

	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		F.StripTextures(_G["TabardFrameCustomization"..i])
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end
end)