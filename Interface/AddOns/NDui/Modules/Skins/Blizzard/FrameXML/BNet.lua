local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- Battlenet toast frame
	B.CreateBD(BNToastFrame)
	B.CreateSD(BNToastFrame)
	B.CreateBD(BNToastFrame.TooltipFrame)
	B.CreateSD(BNToastFrame.TooltipFrame)

	-- Battletag invite frame
	B.CreateBD(BattleTagInviteFrame)
	B.CreateSD(BattleTagInviteFrame)
	local send, cancel = BattleTagInviteFrame:GetChildren()
	B.Reskin(send)
	B.Reskin(cancel)
end)