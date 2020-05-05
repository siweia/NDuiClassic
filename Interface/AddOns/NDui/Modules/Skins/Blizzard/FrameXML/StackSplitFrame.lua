local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local StackSplitFrame = StackSplitFrame

	B.StripTextures(StackSplitFrame)
	B.SetBD(StackSplitFrame, 10, -10, -10, 10)
	B.Reskin(StackSplitOkayButton)
	B.Reskin(StackSplitCancelButton)
end)