local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(AddonList)
	B.Reskin(AddonListEnableAllButton)
	B.Reskin(AddonListDisableAllButton)
	B.Reskin(AddonListCancelButton)
	B.Reskin(AddonListOkayButton)
	B.ReskinCheck(AddonListForceLoad)
	B.ReskinDropDown(AddonCharacterDropDown)
	B.ReskinScroll(AddonListScrollFrameScrollBar)

	AddonCharacterDropDown:SetWidth(170)

	local r, g, b = DB.r, DB.g, DB.b
	hooksecurefunc("AddonList_Update", function()
		for i = 1, MAX_ADDONS_DISPLAYED do
			local checkbox = _G["AddonListEntry"..i.."Enabled"]
			if not checkbox.styled then
				B.ReskinCheck(checkbox)
				checkbox.styled = true
			end
			local ch = checkbox:GetCheckedTexture()
			ch:SetDesaturated(true)
			ch:SetVertexColor(r, g, b)
			B.Reskin(_G["AddonListEntry"..i.."Load"])
		end
	end)
end)