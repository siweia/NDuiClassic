local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local RecruitAFriendFrame = RecruitAFriendFrame
	local RecruitAFriendSentFrame = RecruitAFriendSentFrame

	RecruitAFriendFrame.NoteFrame:DisableDrawLayer("BACKGROUND")

	B.CreateBD(RecruitAFriendFrame)
	B.ReskinClose(RecruitAFriendFrameCloseButton)
	B.Reskin(RecruitAFriendFrame.SendButton)
	B.ReskinInput(RecruitAFriendNameEditBox)

	B.CreateBDFrame(RecruitAFriendFrame.NoteFrame, .25)

	B.CreateBD(RecruitAFriendSentFrame)
	B.Reskin(RecruitAFriendSentFrame.OKButton)
	B.ReskinClose(RecruitAFriendSentFrameCloseButton)
end)