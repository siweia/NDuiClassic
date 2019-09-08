local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if not AuroraConfig.loot then return end

	LootFramePortraitOverlay:Hide()

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local ic = _G["LootButton"..index.."IconTexture"]
		if not ic then return end

		if not ic.bg then
			local bu = _G["LootButton"..index]

			_G["LootButton"..index.."NameFrame"]:Hide()

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			bu.IconBorder:SetAlpha(0)

			local bd = F.CreateBDFrame(bu, .25)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 114, 0)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)
		end

		if select(7, GetLootSlotInfo(index)) then
			ic.bg:SetVertexColor(1, 1, 0)
		else
			ic.bg:SetVertexColor(0, 0, 0)
		end
	end)

	LootFrameDownButton:ClearAllPoints()
	LootFrameDownButton:SetPoint("BOTTOMRIGHT", -8, 6)
	LootFramePrev:ClearAllPoints()
	LootFramePrev:SetPoint("LEFT", LootFrameUpButton, "RIGHT", 4, 0)
	LootFrameNext:ClearAllPoints()
	LootFrameNext:SetPoint("RIGHT", LootFrameDownButton, "LEFT", -4, 0)

	F.ReskinPortraitFrame(LootFrame)
	F.ReskinArrow(LootFrameUpButton, "up")
	F.ReskinArrow(LootFrameDownButton, "down")

	-- Loot Roll Frame

	hooksecurefunc("GroupLootFrame_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			if not frame.styled then
				frame.bg = F.CreateBDFrame(frame)
				F.CreateSD(frame)

				frame.Timer.Bar:SetTexture(C.media.backdrop)
				frame.Timer.Bar:SetVertexColor(1, .8, 0)
				frame.Timer.Background:SetAlpha(0)
				F.CreateBDFrame(frame.Timer, .25)

				local icon = frame.IconFrame.Icon
				F.ReskinIcon(icon)
				local bg = F.CreateBDFrame(frame, .25)
				bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 1)
				bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 150, -1)

				frame.styled = true
			end

			if frame:IsShown() then
				local _, _, _, quality = GetLootRollItemInfo(frame.rollID)
				local color = BAG_ITEM_QUALITY_COLORS[quality]
				frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end)
end)