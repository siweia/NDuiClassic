local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["Loot"] then return end

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

			local bd = B.CreateBDFrame(bu, .25)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 114, 0)

			ic.bg = B.ReskinIcon(ic)
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

	B.ReskinPortraitFrame(LootFrame)
	B.ReskinArrow(LootFrameUpButton, "up")
	B.ReskinArrow(LootFrameDownButton, "down")

	-- Master looter frame

	local MasterLooterFrame = MasterLooterFrame

	B.StripTextures(MasterLooterFrame)
	MasterLooterFrame.Background:Hide()
	B.StripTextures(MasterLooterFrame.Item)
	MasterLooterFrame.Item.Icon:SetTexCoord(.08, .92, .08, .92)
	MasterLooterFrame.Item.bg = B.CreateBDFrame(MasterLooterFrame.Item.Icon)

	MasterLooterFrame:HookScript("OnShow", function(self)
		local color = C.QualityColors[LootFrame.selectedQuality or 1]
		self.Item.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		LootFrame:SetAlpha(.4)
	end)

	MasterLooterFrame:HookScript("OnHide", function(self)
		LootFrame:SetAlpha(1)
	end)

	B.ReskinClose(select(3, MasterLooterFrame:GetChildren()))
	B.SetBD(MasterLooterFrame)

	hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
		for i = 1, MAX_RAID_MEMBERS do
			local playerFrame = MasterLooterFrame["player"..i]
			if playerFrame then
				if not playerFrame.styled then
					playerFrame.Bg:Hide()
					local bg = B.CreateBDFrame(playerFrame, .25)
					playerFrame.Highlight:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
					playerFrame.Highlight:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
					playerFrame.Highlight:SetColorTexture(1, 1, 1, .25)

					playerFrame.styled = true
				end
			else
				break
			end
		end
	end)

	-- Loot Roll Frame

	hooksecurefunc("GroupLootFrame_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			B.StripTextures(frame)
			if not frame.styled then
				frame.bg = B.CreateBDFrame(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 8)
				B.CreateSD(frame.bg)
				if frame.bg.Shadow then
					frame.bg.Shadow:SetFrameLevel(0)
				end

				B.ReskinClose(frame.PassButton, "TOPRIGHT", frame.bg, "TOPRIGHT", -5, -5)

				B.StripTextures(frame.Timer)
				frame.Timer.Bar:SetTexture(DB.bdTex)
				frame.Timer.Bar:SetVertexColor(1, .8, 0)
				frame.Timer.Background:SetAlpha(0)
				B.CreateBDFrame(frame.Timer, .25)

				local icon = frame.IconFrame.Icon
				icon:ClearAllPoints()
				icon:SetPoint("BOTTOMLEFT", frame.Timer, "TOPLEFT", 0, 5)
				
				icon.bg = B.ReskinIcon(icon)
				local bg = B.CreateBDFrame(frame, .25)
				bg:SetPoint("TOPLEFT", icon.bg, "TOPRIGHT", 2, 0)
				bg:SetPoint("BOTTOMRIGHT", frame.Timer, "TOPRIGHT", C.mult, 5)

				frame.styled = true
			end

			if frame:IsShown() then
				local quality = select(4, GetLootRollItemInfo(frame.rollID))
				local color = C.QualityColors[quality or 1]
				frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end)
end)