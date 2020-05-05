local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if NDuiDB["Bags"]["Enable"] then return end
	if not NDuiDB["Skins"]["DefaultBags"] then return end

	for i = 1, 12 do
		local con = _G["ContainerFrame"..i]
		local name = _G["ContainerFrame"..i.."Name"]

		B.StripTextures(con, 0)
		con.PortraitButton.Highlight:SetTexture("")

		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)

		for k = 1, MAX_CONTAINER_ITEMS do
			local item = "ContainerFrame"..i.."Item"..k
			local button = _G[item]
			local searchOverlay = button.searchOverlay
			local questTexture = _G[item.."IconQuestTexture"]
			local newItemTexture = button.NewItemTexture

			questTexture:SetDrawLayer("BACKGROUND")
			questTexture:SetSize(1, 1)

			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.icon:SetTexCoord(.08, .92, .08, .92)
			button.bg = B.CreateBDFrame(button, .25)

			-- easiest way to 'hide' it without breaking stuff
			newItemTexture:SetDrawLayer("BACKGROUND")
			newItemTexture:SetSize(1, 1)

			searchOverlay:SetPoint("TOPLEFT", -C.mult, C.mult)
			searchOverlay:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
		end

		local f = B.CreateBDFrame(con)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)
		B.CreateSD(f)

		B.ReskinClose(_G["ContainerFrame"..i.."CloseButton"], "TOPRIGHT", con, "TOPRIGHT", -6, -6)
	end

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local name = frame:GetName()

		for i = 1, frame.size do
			local itemButton = _G[name.."Item"..i]
			if itemButton.bg then
				local texture, _, _, quality = GetContainerItemInfo(id, itemButton:GetID())
				if texture and quality and quality > 1 then
					local color = C.QualityColors[quality]
					itemButton.bg:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					itemButton.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end)