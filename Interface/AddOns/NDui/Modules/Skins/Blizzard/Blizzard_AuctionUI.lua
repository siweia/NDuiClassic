local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AuctionUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.SetBD(AuctionFrame, 2, -10, 0, 10)
	B.CreateBD(AuctionProgressFrame)
	B.CreateSD(AuctionProgressFrame)

	AuctionProgressBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(AuctionProgressBar, .25)
	B.ReskinIcon(AuctionProgressBar.Icon)

	AuctionProgressBar.Text:ClearAllPoints()
	AuctionProgressBar.Text:SetPoint("CENTER", 0, 1)
	B.ReskinClose(AuctionProgressFrameCancelButton, "LEFT", AuctionProgressBar, "RIGHT", 4, 0)
	select(14, AuctionProgressFrameCancelButton:GetRegions()):SetPoint("CENTER", 0, 2)

	AuctionFrame:DisableDrawLayer("ARTWORK")
	AuctionPortraitTexture:Hide()
	for i = 1, 4 do
		select(i, AuctionProgressFrame:GetRegions()):Hide()
	end
	BrowseFilterScrollFrame:GetRegions():Hide()
	select(2, BrowseFilterScrollFrame:GetRegions()):Hide()
	BrowseScrollFrame:GetRegions():Hide()
	select(2, BrowseScrollFrame:GetRegions()):Hide()
	BidScrollFrame:GetRegions():Hide()
	select(2, BidScrollFrame:GetRegions()):Hide()
	AuctionsScrollFrame:GetRegions():Hide()
	select(2, AuctionsScrollFrame:GetRegions()):Hide()
	BrowseQualitySort:DisableDrawLayer("BACKGROUND")
	BrowseLevelSort:DisableDrawLayer("BACKGROUND")
	BrowseDurationSort:DisableDrawLayer("BACKGROUND")
	BrowseHighBidderSort:DisableDrawLayer("BACKGROUND")
	BrowseCurrentBidSort:DisableDrawLayer("BACKGROUND")
	BidQualitySort:DisableDrawLayer("BACKGROUND")
	BidLevelSort:DisableDrawLayer("BACKGROUND")
	BidDurationSort:DisableDrawLayer("BACKGROUND")
	BidBuyoutSort:DisableDrawLayer("BACKGROUND")
	BidStatusSort:DisableDrawLayer("BACKGROUND")
	BidBidSort:DisableDrawLayer("BACKGROUND")
	AuctionsQualitySort:DisableDrawLayer("BACKGROUND")
	AuctionsDurationSort:DisableDrawLayer("BACKGROUND")
	AuctionsHighBidderSort:DisableDrawLayer("BACKGROUND")
	AuctionsBidSort:DisableDrawLayer("BACKGROUND")
	select(6, BrowseCloseButton:GetRegions()):Hide()
	select(6, BrowseBuyoutButton:GetRegions()):Hide()
	select(6, BrowseBidButton:GetRegions()):Hide()
	select(6, BidCloseButton:GetRegions()):Hide()
	select(6, BidBuyoutButton:GetRegions()):Hide()
	select(6, BidBidButton:GetRegions()):Hide()

	hooksecurefunc("FilterButton_SetUp", function(button)
		button:SetNormalTexture("")
	end)

	local lastSkinnedTab = 1
	AuctionFrame:HookScript("OnShow", function()
		local tab = _G["AuctionFrameTab"..lastSkinnedTab]

		while tab do
			B.ReskinTab(tab)
			lastSkinnedTab = lastSkinnedTab + 1
			tab = _G["AuctionFrameTab"..lastSkinnedTab]
		end
	end)

	local abuttons = {"BrowseBidButton", "BrowseBuyoutButton", "BrowseCloseButton", "BrowseSearchButton", "BidBidButton", "BidBuyoutButton", "BidCloseButton", "AuctionsCloseButton", "AuctionsCancelAuctionButton", "AuctionsCreateAuctionButton", "AuctionsNumStacksMaxButton", "AuctionsStackSizeMaxButton"}
	for i = 1, #abuttons do
		local bu = _G[abuttons[i]]
		if not bu then
			print(abuttons[i])
		else
			B.Reskin(_G[abuttons[i]])
		end
	end

	BrowseCloseButton:ClearAllPoints()
	BrowseCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOMRIGHT", 66, 13)
	BrowseBuyoutButton:ClearAllPoints()
	BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -1, 0)
	BrowseBidButton:ClearAllPoints()
	BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -1, 0)
	BidBuyoutButton:ClearAllPoints()
	BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -1, 0)
	BidBidButton:ClearAllPoints()
	BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -1, 0)
	AuctionsCancelAuctionButton:ClearAllPoints()
	AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -1, 0)

	-- Blizz needs to be more consistent
--[[
	BrowseBidPriceSilver:SetPoint("LEFT", BrowseBidPriceGold, "RIGHT", 1, 0)
	BrowseBidPriceCopper:SetPoint("LEFT", BrowseBidPriceSilver, "RIGHT", 1, 0)
	BidBidPriceSilver:SetPoint("LEFT", BidBidPriceGold, "RIGHT", 1, 0)
	BidBidPriceCopper:SetPoint("LEFT", BidBidPriceSilver, "RIGHT", 1, 0)
	StartPriceSilver:SetPoint("LEFT", StartPriceGold, "RIGHT", 1, 0)
	StartPriceCopper:SetPoint("LEFT", StartPriceSilver, "RIGHT", 1, 0)
	BuyoutPriceSilver:SetPoint("LEFT", BuyoutPriceGold, "RIGHT", 1, 0)
	BuyoutPriceCopper:SetPoint("LEFT", BuyoutPriceSilver, "RIGHT", 1, 0)]]

	local function reskinAuctionButtons(button, i)
		local bu = _G[button..i]
		local it = _G[button..i.."Item"]
		local ic = _G[button..i.."ItemIconTexture"]

		if bu and it then
			it:SetNormalTexture("")
			it:SetPushedTexture("")
			local itemHL = it:GetHighlightTexture()
			if itemHL then
				itemHL:SetColorTexture(1, 1, 1, .25)
			end
			B.ReskinIcon(ic)
			it.IconBorder:SetAlpha(0)
			B.StripTextures(bu)

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 5)

			bu:SetHighlightTexture(DB.bdTex)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)
		end
	end

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		reskinAuctionButtons("BrowseButton", i)
	end

	for i = 1, NUM_BIDS_TO_DISPLAY do
		reskinAuctionButtons("BidButton", i)
	end

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		reskinAuctionButtons("AuctionsButton", i)
	end

	local auctionhandler = CreateFrame("Frame")
	auctionhandler:RegisterEvent("NEW_AUCTION_UPDATE")
	auctionhandler:SetScript("OnEvent", function()
		local AuctionsItemButtonIconTexture = AuctionsItemButton:GetNormalTexture()
		if AuctionsItemButtonIconTexture then
			AuctionsItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			AuctionsItemButtonIconTexture:SetPoint("TOPLEFT", C.mult, -C.mult)
			AuctionsItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		end
		AuctionsItemButton.IconBorder:SetTexture("")
	end)

	B.CreateBD(AuctionsItemButton, .25)
	local _, AuctionsItemButtonNameFrame = AuctionsItemButton:GetRegions()
	AuctionsItemButtonNameFrame:Hide()
	local hl = AuctionsItemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetPoint("TOPLEFT", C.mult, -C.mult)
	hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

	B.ReskinClose(AuctionFrameCloseButton, "TOPRIGHT", AuctionFrame, "TOPRIGHT", -4, -14)
	B.ReskinScroll(BrowseScrollFrameScrollBar)
	B.ReskinScroll(AuctionsScrollFrameScrollBar)
	B.ReskinScroll(BrowseFilterScrollFrameScrollBar)
	B.ReskinDropDown(PriceDropDown)
	B.ReskinInput(BrowseName)
	B.ReskinArrow(BrowsePrevPageButton, "left")
	B.ReskinArrow(BrowseNextPageButton, "right")
	B.ReskinCheck(IsUsableCheckButton)
	B.ReskinCheck(ShowOnPlayerCheckButton)
	B.ReskinRadio(AuctionsShortAuctionButton)
	B.ReskinRadio(AuctionsMediumAuctionButton)
	B.ReskinRadio(AuctionsLongAuctionButton)

	BrowseDropDownLeft:SetAlpha(0)
	BrowseDropDownMiddle:SetAlpha(0)
	BrowseDropDownRight:SetAlpha(0)

	local a1, p, a2, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(a1, p, a2, x, y-4)
	BrowseDropDownButton:SetSize(16, 16)
	B.Reskin(BrowseDropDownButton, true)

	local tex = BrowseDropDownButton:CreateTexture(nil, "OVERLAY")
	tex:SetTexture(DB.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	BrowseDropDownButton.bgTex = tex

	local bg = B.CreateBDFrame(BrowseDropDown, 0)
	bg:SetPoint("TOPLEFT", 16, -5)
	bg:SetPoint("BOTTOMRIGHT", 109, 11)
	B.CreateGradient(bg)

	local colourArrow = B.colourArrow
	local clearArrow = B.clearArrow

	BrowseDropDownButton:HookScript("OnEnter", colourArrow)
	BrowseDropDownButton:HookScript("OnLeave", clearArrow)

	local inputs = {"BrowseMinLevel", "BrowseMaxLevel", "BrowseBidPriceGold", "BrowseBidPriceSilver", "BrowseBidPriceCopper", "BidBidPriceGold", "BidBidPriceSilver", "BidBidPriceCopper", "StartPriceGold", "StartPriceSilver", "StartPriceCopper", "BuyoutPriceGold", "BuyoutPriceSilver", "BuyoutPriceCopper", "AuctionsStackSizeEntry", "AuctionsNumStacksEntry"}
	for i = 1, #inputs do
		B.ReskinInput(_G[inputs[i]])
	end

	-- [[ WoW token ]]

	local BrowseWowTokenResults = BrowseWowTokenResults

	B.Reskin(BrowseWowTokenResults.Buyout)
	B.ReskinPortraitFrame(WowTokenGameTimeTutorial)
	B.Reskin(StoreButton)
	WowTokenGameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, .8, 0)
	WowTokenGameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, .8, 0)

	-- Token

	do
		local Token = BrowseWowTokenResults.Token
		local icon = Token.Icon
		local iconBorder = Token.IconBorder

		Token.ItemBorder:Hide()
		iconBorder:SetTexture(DB.bdTex)
		iconBorder:SetDrawLayer("BACKGROUND")
		iconBorder:SetPoint("TOPLEFT", icon, -C.mult, C.mult)
		iconBorder:SetPoint("BOTTOMRIGHT", icon, C.mult, -C.mult)
		icon:SetTexCoord(.08, .92, .08, .92)
	end
end