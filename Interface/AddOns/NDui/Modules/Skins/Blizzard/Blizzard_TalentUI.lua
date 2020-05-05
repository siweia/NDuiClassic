local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TalentUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(TalentFrame, 20, -10, -33, 75)
	B.Reskin(TalentFrameCancelButton)
	B.ReskinScroll(TalentFrameScrollFrameScrollBar)
	for i = 1, 3 do
		local tab = _G["TalentFrameTab"..i]
		B.ReskinTab(tab)
	end
	B.StripTextures(TalentFrameScrollFrame)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["TalentFrameTalent"..i]
		local icon = _G["TalentFrameTalent"..i.."IconTexture"]
		if talent then
			B.StripTextures(talent)
			icon:SetTexCoord(.08, .92, .08, .92)
			B.CreateBDFrame(icon)
		end
	end
end