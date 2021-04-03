local _, ns = ...
local B, C, L, DB = unpack(ns)

local backpackTexture = "Interface\\Buttons\\Button-Backpack-Up"
local bagIDToInvID = {
	[1] = 20,
	[2] = 21,
	[3] = 22,
	[4] = 23,
	[5] = 80,
	[6] = 81,
	[7] = 82,
	[8] = 83,
	[9] = 84,
	[10] = 85,
	[11] = 86,
}

local function createBagIcon(frame, index)
	if not frame.bagIcon then
		frame.bagIcon = frame.PortraitButton:CreateTexture()
		B.ReskinIcon(frame.bagIcon)
		frame.bagIcon:SetPoint("TOPLEFT", 5, -3)
		frame.bagIcon:SetSize(32, 32)
	end
	if index == 1 then
		frame.bagIcon:SetTexture(backpackTexture) -- backpack
	end
end

tinsert(C.defaultThemes, function()
	if C.db["Bags"]["Enable"] then return end
	if not C.db["Skins"]["DefaultBags"] then return end

	for i = 1, 12 do
		local con = _G["ContainerFrame"..i]
		local name = _G["ContainerFrame"..i.."Name"]

		B.StripTextures(con, 0)
		createBagIcon(con, i)
		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)

		for k = 1, MAX_CONTAINER_ITEMS do
			local item = "ContainerFrame"..i.."Item"..k
			local button = _G[item]
			local searchOverlay = button.searchOverlay
			local questTexture = _G[item.."IconQuestTexture"]

			questTexture:SetDrawLayer("BACKGROUND")
			questTexture:SetSize(1, 1)

			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.icon:SetTexCoord(.08, .92, .08, .92)
			button.bg = B.CreateBDFrame(button, .25)

			searchOverlay:SetPoint("TOPLEFT", -C.mult, C.mult)
			searchOverlay:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
		end

		local f = B.CreateBDFrame(con, nil, true)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)

		B.ReskinClose(_G["ContainerFrame"..i.."CloseButton"], con, -6, -6)
	end

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local name = frame:GetName()

		for i = 1, frame.size do
			local itemButton = _G[name.."Item"..i]
			if itemButton.bg then
				local texture, _, _, quality = GetContainerItemInfo(id, itemButton:GetID())
				if texture and quality and quality > 1 then
					local color = DB.QualityColors[quality]
					itemButton.bg:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					itemButton.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end

		if frame.bagIcon then
			local invID = bagIDToInvID[id]
			if invID then
				local icon = GetInventoryItemTexture("player", invID)
				frame.bagIcon:SetTexture(icon or backpackTexture)
			end
		end
	end)
end)