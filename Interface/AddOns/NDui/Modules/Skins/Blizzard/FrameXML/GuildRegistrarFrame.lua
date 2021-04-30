local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	GuildRegistrarFrameEditBox:SetHeight(20)
	GuildAvailableServicesText:SetTextColor(1, 1, 1)
	GuildAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(GuildRegistrarFrame)
	B.CreateBDFrame(GuildRegistrarFrameEditBox, .25)
	B.Reskin(GuildRegistrarFrameGoodbyeButton)
	B.Reskin(GuildRegistrarFramePurchaseButton)
	B.Reskin(GuildRegistrarFrameCancelButton)
end)