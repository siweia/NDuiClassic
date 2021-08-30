local _, ns = ...
local B, C, L, DB = unpack(ns)

-- /run LoadAddOn'Blizzard_GuildBankUI' GuildBankFrame:Show()

C.themes["Blizzard_GuildBankUI"] = function()
	B.StripTextures(GuildBankFrame)
	B.SetBD(GuildBankFrame, nil, 10, 0, 0, 6)
	local closeButton = select(11, GuildBankFrame:GetChildren())
	if closeButton then B.ReskinClose(closeButton) end

	GuildBankFrame.Emblem:SetAlpha(0)
	B.Reskin(GuildBankFrame.WithdrawButton)
	B.Reskin(GuildBankFrame.DepositButton)
	B.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	B.ReskinScroll(GuildBankInfoScrollFrameScrollBar)

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		B.ReskinTab(tab)

		if i ~= 1 then
			tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	for i = 1, 7 do
		local column = GuildBankFrame["Column"..i]
		column:GetRegions():Hide()

		for j = 1, 14 do
			local button = column["Button"..j]
			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button, .3)
			button.bg:SetBackdropColor(.3, .3, .3, .3)
			button.searchOverlay:SetOutside()
			B.ReskinIconBorder(button.IconBorder)
		end
	end
end