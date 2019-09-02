local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if C.isClassic then return end

	F.CreateBD(GuildInviteFrame)
	F.CreateSD(GuildInviteFrame)
	for i = 1, 10 do
		select(i, GuildInviteFrame:GetRegions()):Hide()
	end
	F.Reskin(GuildInviteFrameJoinButton)
	F.Reskin(GuildInviteFrameDeclineButton)
end)