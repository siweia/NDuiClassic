local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(BattlefieldFrame, 15, -15, -35, 73)
	F.ReskinScroll(BattlefieldListScrollFrameScrollBar)
	F.Reskin(BattlefieldFrameJoinButton)
	F.Reskin(BattlefieldFrameCancelButton)
	F.Reskin(BattlefieldFrameGroupJoinButton)
	BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)

	F.ReskinPortraitFrame(WorldStateScoreFrame, 13, -15, -120, 70)
	F.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	for i = 1, 3 do
		F.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end
	F.Reskin(WorldStateScoreFrameLeaveButton)
end)