local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	ColorPickerFrameHeader:SetAlpha(0)
	ColorPickerFrameHeader:ClearAllPoints()
	ColorPickerFrameHeader:SetPoint("TOP", ColorPickerFrame, 0, 0)

	ColorPickerFrame:SetBackdrop(nil)
	B.SetBD(ColorPickerFrame)
	B.Reskin(ColorPickerOkayButton)
	B.Reskin(ColorPickerCancelButton)
	B.ReskinSlider(OpacitySliderFrame, true)
end)