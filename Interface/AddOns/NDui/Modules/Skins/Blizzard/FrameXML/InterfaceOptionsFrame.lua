local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local restyled = false

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if restyled then return end

		B.StripTextures(InterfaceOptionsFrame)
		B.StripTextures(InterfaceOptionsFrameCategories)
		B.StripTextures(InterfaceOptionsFramePanelContainer)
		B.StripTextures(InterfaceOptionsFrameAddOns)
		for i = 1, 2 do
			B.StripTextures(_G["InterfaceOptionsFrameTab"..i])
		end
		B.SetBD(InterfaceOptionsFrame)

		InterfaceOptionsFrameHeader:SetTexture("")
		InterfaceOptionsFrameHeader:ClearAllPoints()
		InterfaceOptionsFrameHeader:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetColorTexture(1, 1, 1, .25)

		local buttons = {
			"InterfaceOptionsFrameDefaults",
			"InterfaceOptionsFrameOkay",
			"InterfaceOptionsFrameCancel",
			"InterfaceOptionsSocialPanelRedockChat",
			"InterfaceOptionsSocialPanelTwitterLoginButton",
			"InterfaceOptionsDisplayPanelResetTutorials",
		}
		for _, buttonName in pairs(buttons) do
			local button = _G[buttonName]
			if not button then
				if DB.isDeveloper then print(buttonName, "not found.") end
			else
				B.Reskin(button)
			end
		end

		local checkboxes = {
			"InterfaceOptionsControlsPanelStickyTargeting",
			"InterfaceOptionsControlsPanelAutoDismount",
			"InterfaceOptionsControlsPanelAutoClearAFK",
			"InterfaceOptionsControlsPanelAutoLootCorpse",
			"InterfaceOptionsControlsPanelInteractOnLeftClick",
			"InterfaceOptionsControlsPanelLootAtMouse",
			"InterfaceOptionsCombatPanelTargetOfTarget",
			"InterfaceOptionsCombatPanelFlashLowHealthWarning",
			"InterfaceOptionsCombatPanelEnableFloatingCombatText",
			"InterfaceOptionsCombatPanelAutoSelfCast",
			"InterfaceOptionsDisplayPanelRotateMinimap",
			"InterfaceOptionsDisplayPanelShowTutorials",
			"InterfaceOptionsSocialPanelProfanityFilter",
			"InterfaceOptionsSocialPanelSpamFilter",
			"InterfaceOptionsSocialPanelGuildMemberAlert",
			"InterfaceOptionsSocialPanelBlockTrades",
			"InterfaceOptionsSocialPanelBlockGuildInvites",
			"InterfaceOptionsSocialPanelBlockChatChannelInvites",
			"InterfaceOptionsSocialPanelOnlineFriends",
			"InterfaceOptionsSocialPanelOfflineFriends",
			"InterfaceOptionsSocialPanelBroadcasts",
			"InterfaceOptionsSocialPanelFriendRequests",
			"InterfaceOptionsSocialPanelShowToastWindow",
			"InterfaceOptionsSocialPanelEnableTwitter",
			"InterfaceOptionsActionBarsPanelBottomLeft",
			"InterfaceOptionsActionBarsPanelBottomRight",
			"InterfaceOptionsActionBarsPanelRight",
			"InterfaceOptionsActionBarsPanelRightTwo",
			"InterfaceOptionsActionBarsPanelStackRightBars",
			"InterfaceOptionsActionBarsPanelLockActionBars",
			"InterfaceOptionsActionBarsPanelAlwaysShowActionBars",
			"InterfaceOptionsActionBarsPanelCountdownCooldowns",
			"InterfaceOptionsNamesPanelMyName",
			"InterfaceOptionsNamesPanelGuildNames",
			"InterfaceOptionsNamesPanelNonCombatCreature",
			"InterfaceOptionsNamesPanelFriendlyPlayerNames",
			"InterfaceOptionsNamesPanelFriendlyMinions",
			"InterfaceOptionsNamesPanelEnemyPlayerNames",
			"InterfaceOptionsNamesPanelEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesShowAll",
			"InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemies",
			"InterfaceOptionsNamesPanelUnitNameplatesFriends",
			"InterfaceOptionsCameraPanelWaterCollision",
			"InterfaceOptionsMousePanelInvertMouse",
			"InterfaceOptionsMousePanelEnableMouseSpeed",
			"InterfaceOptionsMousePanelClickToMove",
			"InterfaceOptionsMousePanelLockCursorToScreen",
			"InterfaceOptionsAccessibilityPanelMovePad",
			"InterfaceOptionsAccessibilityPanelCinematicSubtitles",
			"InterfaceOptionsAccessibilityPanelColorblindMode",
			"InterfaceOptionsCombatPanelCombatTextLowManaHealth",
			"InterfaceOptionsCombatPanelCombatTextAuras",
			"InterfaceOptionsCombatPanelCombatTextAuraFade",
			"InterfaceOptionsCombatPanelCombatTextState",
			"InterfaceOptionsCombatPanelCombatTextParryDodgeMiss",
			"InterfaceOptionsCombatPanelCombatTextResistances",
			"InterfaceOptionsCombatPanelCombatTextReputation",
			"InterfaceOptionsCombatPanelCombatTextReactives",
			"InterfaceOptionsCombatPanelCombatTextFriendlyNames",
			"InterfaceOptionsCombatPanelCombatTextComboPoints",
			"InterfaceOptionsCombatPanelCombatTextEnergyGains",
			"InterfaceOptionsCombatPanelCombatTextHonorGains",
			"InterfaceOptionsCombatPanelEnableCombatDamage",
			"InterfaceOptionsCombatPanelEnableCombatHealing",
			"InterfaceOptionsCombatPanelEnablePeriodicDamage",
			"InterfaceOptionsCombatPanelEnablePetDamage",
			"InterfaceOptionsDisplayPanelShowHelm",
			"InterfaceOptionsDisplayPanelShowCloak",
			"InterfaceOptionsDisplayPanelInstantQuestText",
			"InterfaceOptionsDisplayPanelAutoQuestWatch",
			"InterfaceOptionsDisplayPanelHideOutdoorWorldState",
			"InterfaceOptionsDisplayPanelShowMinimapClock",
			"InterfaceOptionsDisplayPanelShowDetailedTooltips",
			"InterfaceOptionsDisplayPanelShowLoadingScreenTip",
			"InterfaceOptionsSocialPanelShowLootSpam",
			"InterfaceOptionsNamesPanelNPCNames",
			"InterfaceOptionsNamesPanelTitles",
			"InterfaceOptionsCameraPanelFollowTerrain",
			"InterfaceOptionsCameraPanelHeadBob",
			"InterfaceOptionsCameraPanelSmartPivot",
		}
		for _, boxName in pairs(checkboxes) do
			local checkbox = _G[boxName]
			if not checkbox then
				if DB.isDeveloper then print(boxName, "not found.") end
			else
				B.ReskinCheck(checkbox)
			end
		end

		local dropdowns = {
			"InterfaceOptionsControlsPanelAutoLootKeyDropDown",
			"InterfaceOptionsCombatPanelFocusCastKeyDropDown",
			"InterfaceOptionsCombatPanelSelfCastKeyDropDown",
			"InterfaceOptionsDisplayPanelDisplayDropDown",
			"InterfaceOptionsDisplayPanelChatBubblesDropDown",
			"InterfaceOptionsSocialPanelChatStyle",
			"InterfaceOptionsSocialPanelTimestamps",
			"InterfaceOptionsSocialPanelWhisperMode",
			"InterfaceOptionsActionBarsPanelPickupActionKeyDropDown",
			"InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown",
			"InterfaceOptionsCameraPanelStyleDropDown",
			"InterfaceOptionsMousePanelClickMoveStyleDropDown",
			"InterfaceOptionsAccessibilityPanelColorFilterDropDown",
			"InterfaceOptionsCombatPanelCombatTextFloatModeDropDown",
		}
		for _, ddName in pairs(dropdowns) do
			local dropdown = _G[ddName]
			if not dropdown then
				if DB.isDeveloper then print(ddName, "not found.") end
			else
				B.ReskinDropDown(dropdown)
			end
		end

		local sliders = {
			"InterfaceOptionsCameraPanelFollowSpeedSlider",
			"InterfaceOptionsMousePanelMouseSensitivitySlider",
			"InterfaceOptionsMousePanelMouseLookSpeedSlider",
			"InterfaceOptionsAccessibilityPanelColorblindStrengthSlider",
			"InterfaceOptionsCameraPanelMaxDistanceSlider",
		}
		for _, sliderName in pairs(sliders) do
			local slider = _G[sliderName]
			if not slider then
				if DB.isDeveloper then print(sliderName, "not found.") end
			else
				B.ReskinSlider(slider)
			end
		end

		if IsAddOnLoaded("Blizzard_CUFProfiles") then
			CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()

			local boxes = {
				"CompactUnitFrameProfilesRaidStylePartyFrames",
				"CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether",
				"CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar",
				"CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder",
				"CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs",
				"CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate20Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP",
				"CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE",
			}
			for _, boxName in pairs(boxes) do
				local checkbox = _G[boxName]
				if not checkbox then
					if DB.isDeveloper then print(boxName, "not found.") end
				else
					B.ReskinCheck(checkbox)
				end
			end

			B.Reskin(CompactUnitFrameProfilesSaveButton)
			B.Reskin(CompactUnitFrameProfilesDeleteButton)
			B.Reskin(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
			B.ReskinDropDown(CompactUnitFrameProfilesProfileSelector)
			B.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown)
			B.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown)
			B.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider)
			B.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider)
		end

		restyled = true
	end)

	hooksecurefunc("InterfaceOptions_AddCategory", function()
		local num = #INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, num do
			local bu = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu:GetPushedTexture():SetAlpha(0)

				bu.styled = true
			end
		end
	end)
end)