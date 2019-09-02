local F, C = unpack(select(2, ...))

C.themes["Blizzard_TrainerUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.ReskinPortraitFrame(ClassTrainerFrame, 10, -5, -30, 70)
	F.Reskin(ClassTrainerTrainButton)
	F.Reskin(ClassTrainerCancelButton)
	F.ReskinDropDown(ClassTrainerFrameFilterDropDown)
	F.ReskinScroll(ClassTrainerListScrollFrameScrollBar)
	F.ReskinScroll(ClassTrainerDetailScrollFrameScrollBar)

	F.ReskinExpandOrCollapse(ClassTrainerCollapseAllButton)
	ClassTrainerExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	for i = 1, 11 do
		local bu = _G["ClassTrainerSkill"..i]
		F.ReskinExpandOrCollapse(bu)
	end

	hooksecurefunc("ClassTrainer_SetSelection", function()
		local tex = ClassTrainerSkillIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end
	end)
	F.StripTextures(ClassTrainerSkillIcon)
	F.CreateBDFrame(ClassTrainerSkillIcon)
end