local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.SetBD(ScrollOfResurrectionSelectionFrame)
	B.SetBD(ScrollOfResurrectionFrame)
	B.ReskinScroll(ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar)
	B.ReskinInput(ScrollOfResurrectionSelectionFrameTargetEditBox)
	B.ReskinInput(ScrollOfResurrectionFrameNoteFrame)
	for i = 1, 6 do
		select(i, ScrollOfResurrectionFrameNoteFrame:GetRegions()):Hide()
	end
	B.Reskin(ScrollOfResurrectionSelectionFrameAcceptButton)
	B.Reskin(ScrollOfResurrectionSelectionFrameCancelButton)
	B.Reskin(ScrollOfResurrectionFrameAcceptButton)
	B.Reskin(ScrollOfResurrectionFrameCancelButton)
	B.CreateBD(ScrollOfResurrectionSelectionFrameList, .25)
end)