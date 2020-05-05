local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(GuildRegistrarFrame)
	B.CreateBD(GuildRegistrarFrameEditBox, .25)
	B.Reskin(GuildRegistrarFrameGoodbyeButton)
	B.Reskin(GuildRegistrarFramePurchaseButton)
	B.Reskin(GuildRegistrarFrameCancelButton)
end)