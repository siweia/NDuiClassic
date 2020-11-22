local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Maps")

local select, pairs, unpack, next, tinsert = select, pairs, unpack, next, tinsert
local strmatch, strfind, strupper = strmatch, strfind, strupper
local IsPlayerSpell, GetSpellInfo, GetSpellTexture = IsPlayerSpell, GetSpellInfo, GetSpellTexture
local CastSpellByID, GetTrackingTexture = CastSpellByID, GetTrackingTexture
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local C_Timer_After = C_Timer.After
local cr, cg, cb = DB.r, DB.g, DB.b

function module:CreatePulse()
	if not C.db["Map"]["CombatPulse"] then return end

	local bg = B.CreateBDFrame(Minimap, nil, true)
	local anim = bg:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(.8)
	anim.fader:SetToAlpha(.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapAnim(event)
		if event == "PLAYER_REGEN_DISABLED" then
			bg:SetBackdropBorderColor(1, 0, 0)
			anim:Play()
		elseif not InCombatLockdown() then
			if MiniMapMailFrame:IsShown() then
				bg:SetBackdropBorderColor(1, 1, 0)
				anim:Play()
			else
				anim:Stop()
				bg:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
	B:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapAnim)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapAnim)
	B:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapAnim)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then return end
		anim:Stop()
		bg:SetBackdropBorderColor(0, 0, 0)
	end)
end

function module:ReskinRegions()
	-- Tracking icon
	MiniMapTrackingFrame:SetScale(.7)
	MiniMapTrackingFrame:ClearAllPoints()
	MiniMapTrackingFrame:SetPoint("BOTTOMRIGHT", Minimap, -5, 5)
	MiniMapTrackingBorder:Hide()
	MiniMapTrackingIcon:SetTexCoord(unpack(DB.TexCoord))
	local bg = B.CreateBDFrame(MiniMapTrackingIcon)
	bg:SetBackdropBorderColor(cr, cg, cb)

	-- Mail icon
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
	MiniMapMailIcon:SetTexture(DB.mailTex)
	MiniMapMailIcon:SetSize(21, 21)
	MiniMapMailIcon:SetVertexColor(1, 1, 0)

	-- Battlefield
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -5, -5)
	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldIcon:SetAlpha(0)
	BattlegroundShine:SetTexture(nil)

	local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
	queueIcon:SetPoint("CENTER", MiniMapBattlefieldFrame)
	queueIcon:SetSize(50, 50)
	queueIcon:SetTexture(DB.eyeTex)
	queueIcon:Hide()
	local anim = queueIcon:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	anim.rota = anim:CreateAnimation("Rotation")
	anim.rota:SetDuration(2)
	anim.rota:SetDegrees(360)

	hooksecurefunc("BattlefieldFrame_UpdateStatus", function()
		queueIcon:SetShown(MiniMapBattlefieldFrame:IsShown())

		anim:Play()
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				anim:Stop()
				break
			end
		end
	end)
end

function module:RecycleBin()
	if not C.db["Map"]["ShowRecycleBin"] then return end

	local blackList = {
		["GameTimeFrame"] = true,
		["MiniMapLFGFrame"] = true,
		["BattlefieldMinimap"] = true,
		["MinimapBackdrop"] = true,
		["TimeManagerClockButton"] = true,
		["FeedbackUIButton"] = true,
		["HelpOpenTicketButton"] = true,
		["MiniMapBattlefieldFrame"] = true,
		["QueueStatusMinimapButton"] = true,
		["GarrisonLandingPageMinimapButton"] = true,
		["MinimapZoneTextButton"] = true,
		["RecycleBinFrame"] = true,
		["RecycleBinToggleButton"] = true,
	}

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetSize(24, 24)
	bu:SetPoint("BOTTOMLEFT", -15, -15)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(DB.binTex)
	bu:SetHighlightTexture(DB.binTex)
	B.AddTooltip(bu, "ANCHOR_LEFT", L["Minimap RecycleBin"], "white")

	local width, height, alpha = 220, 40, .5
	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("RIGHT", bu, "LEFT", -3, -6)
	bin:SetSize(width, height)
	bin:SetFrameStrata("LOW")
	bin:Hide()

	local tex = B.SetGradient(bin, "H", 0, 0, 0, 0, alpha, width, height)
	tex:SetPoint("CENTER")
	local topLine = B.SetGradient(bin, "H", cr, cg, cb, 0, alpha, width, C.mult)
	topLine:SetPoint("BOTTOM", bin, "TOP")
	local bottomLine = B.SetGradient(bin, "H", cr, cg, cb, 0, alpha, width, C.mult)
	bottomLine:SetPoint("TOP", bin, "BOTTOM")
	local rightLine = B.SetGradient(bin, "V", cr, cg, cb, alpha, alpha, C.mult, 40 + C.mult*2)
	rightLine:SetPoint("LEFT", bin, "RIGHT")

	local function hideBinButton()
		bin:Hide()
	end
	local function clickFunc()
		UIFrameFadeOut(bin, .5, 1, 0)
		C_Timer_After(.5, hideBinButton)
	end

	local secureAddons = {
		["GatherMatePin"] = true,
		["HandyNotes.-Pin"] = true,
		["Guidelime"] = true,
		["QuestieFrame"] = true,
	}
	local function isButtonSecure(name)
		for addonName in pairs(secureAddons) do
			if strmatch(name, addonName) then
				return true
			end
		end
	end

	local currentIndex, pendingTime, timeThreshold = 0, 5, 12
	local buttons, numMinimapChildren = {}, 0
	local removedTextures = {
		[136430] = true,
		[136467] = true,
	}

	local function ReskinMinimapButton(child)
		for j = 1, child:GetNumRegions() do
			local region = select(j, child:GetRegions())
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture() or ""
				if removedTextures[texture] or strfind(texture, "Interface\\CharacterFrame") or strfind(texture, "Interface\\Minimap") then
					region:SetTexture(nil)
				end
				region:ClearAllPoints()
				region:SetAllPoints()
				region:SetTexCoord(unpack(DB.TexCoord))
			end
			child:SetSize(34, 34)
			B.CreateSD(child, 3, 3)
		end

		tinsert(buttons, child)
	end

	local function KillMinimapButtons()
		for _, child in pairs(buttons) do
			if not child.styled then
				child:SetParent(bin)
				if child:HasScript("OnDragStop") then child:SetScript("OnDragStop", nil) end
				if child:HasScript("OnDragStart") then child:SetScript("OnDragStart", nil) end
				--if child:HasScript("OnClick") then child:HookScript("OnClick", clickFunc) end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture(DB.bdTex) -- prevent nil function
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetAllPoints()
					child.highlight:SetColorTexture(1, 1, 1, .25)
				end

				-- Naughty Addons
				local name = child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					--child:HookScript("OnMouseUp", clickFunc)
				end

				child.styled = true
			end
		end
	end

	local function CollectRubbish()
		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			for i = 1, numChildren do
				local child = select(i, Minimap:GetChildren())
				local name = child and child.GetName and child:GetName()
				if name and not child.isExamed and not blackList[name] then
					if (child:IsObjectType("Button") or strmatch(strupper(name), "BUTTON")) and not isButtonSecure(name) then
						ReskinMinimapButton(child)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		KillMinimapButtons()

		currentIndex = currentIndex + 1
		if currentIndex < timeThreshold then
			C_Timer_After(pendingTime, CollectRubbish)
		end
	end

	local function SortRubbish()
		if #buttons == 0 then return end
		local lastbutton
		for _, button in pairs(buttons) do
			if next(button) and button:IsShown() then -- fix for fuxking AHDB
				button:ClearAllPoints()
				if not lastbutton then
					button:SetPoint("RIGHT", bin, -3, 0)
				else
					button:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
				end
				lastbutton = button
			end
		end
	end

	bu:SetScript("OnClick", function()
		SortRubbish()
		if bin:IsShown() then
			clickFunc()
		else
			UIFrameFadeIn(bin, .5, 0, 1)
		end
	end)

	CollectRubbish()
end

function module:WhoPingsMyMap()
	if not C.db["Map"]["WhoPings"] then return end

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetAllPoints()
	f.text = B.CreateFS(f, 12, "", false, "TOP", 0, -3)

	local anim = f:CreateAnimationGroup()
	anim:SetScript("OnPlay", function() f:SetAlpha(1) end)
	anim:SetScript("OnFinished", function() f:SetAlpha(0) end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(3)

	B:RegisterEvent("MINIMAP_PING", function(_, unit)
		if unit == "player" then return end -- ignore player ping

		local class = select(2, UnitClass(unit))
		local r, g, b = B.ClassColor(class)
		local name = GetUnitName(unit)

		anim:Stop()
		f.text:SetText(name)
		f.text:SetTextColor(r, g, b)
		anim:Play()
	end)
end

function module:UpdateMinimapScale()
	local size = Minimap:GetWidth()
	local scale = C.db["Map"]["MinimapScale"]
	Minimap:SetScale(scale)
	Minimap.mover:SetSize(size*scale, size*scale)
end

function module:ShowMinimapClock()
	if C.db["Map"]["Clock"] then
		if not TimeManagerClockButton then LoadAddOn("Blizzard_TimeManager") end
		if not TimeManagerClockButton.styled then
			TimeManagerClockButton:DisableDrawLayer("BORDER")
			TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -8)
			TimeManagerClockTicker:SetFont(unpack(DB.Font))
			TimeManagerClockTicker:SetTextColor(1, 1, 1)

			TimeManagerClockButton.styled = true
		end
		TimeManagerClockButton:Show()
	else
		if TimeManagerClockButton then TimeManagerClockButton:Hide() end
	end
end

function module:TrackMenu_SetText(spellID)
	local name = GetSpellInfo(spellID)
	local texture = GetSpellTexture(spellID) or 136243
	name = " |T"..texture..":12:12:0:0:50:50:4:46:4:46|t "..name
	return name
end

function module:TrackMenu_OnClick(spellID)
	CastSpellByID(spellID)
end

function module:TrackMenu_CheckStatus()
	local texture = GetSpellTexture(self.arg1)
	if texture == GetTrackingTexture() then
		return true
	end
end

function module:EasyTrackMenu()
	local trackSpells = {
		2383,	--Find Herbs
		2580,	--Find Minerals
		2481,	--Find Treasure
		1494,	--Track Beasts
		19883,	--Track Humanoids
		19884,	--Track Undead
		19885,	--Track Hidden
		19880,	--Track Elementals
		19878,	--Track Demons
		19882,	--Track Giants
		19879,	--Track Dragonkin
		5225,	--Track Humanoids: Druid
		5500,	--Sense Demons
		5502,	--Sense Undead
	}

	local menuList = {
		[1] = {text = L["TrackMenu"], isTitle = true, notCheckable = true},
	}

	local function updateMenuList()
		for i = 2, #menuList do
			if menuList[i] then wipe(menuList[i]) end
		end

		local index = 2
		for _, spellID in pairs(trackSpells) do
			if IsPlayerSpell(spellID) then
				if not menuList[index] then menuList[index] = {} end
				menuList[index].arg1 = spellID
				menuList[index].text = module:TrackMenu_SetText(spellID)
				menuList[index].func = module.TrackMenu_OnClick
				menuList[index].checked = module.TrackMenu_CheckStatus

				index = index + 1
			end
		end

		return index
	end

	local function toggleTrackMenu(self)
		if DropDownList1:IsShown() then
			DropDownList1:Hide()
		else
			local index = updateMenuList()
			if index > 2 then
				local offset = self:GetWidth()*self:GetScale()*.5
				EasyMenu(menuList, B.EasyMenu, self, -offset, offset, "MENU")
			end
		end
	end

	-- Click Func
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			toggleTrackMenu(self)
		else
			Minimap_OnClick(self)
		end
	end)
end

function module:SetupMinimap()
	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	DropDownList1:SetClampedToScreen(true)

	local mover = B.Mover(Minimap, L["Minimap"], "Minimap", C.Minimap.Pos)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", mover)
	Minimap.mover = mover

	self:UpdateMinimapScale()
	self:ShowMinimapClock()

	-- Mousewheel Zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, zoom)
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	-- Hide Blizz
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MinimapToggleButton",
		"GameTimeFrame",
	}

	for _, v in pairs(frames) do
		B.HideObject(_G[v])
	end
	MinimapCluster:EnableMouse(false)

	-- Add Elements
	self:CreatePulse()
	self:ReskinRegions()
	self:RecycleBin()
	self:WhoPingsMyMap()
	self:EasyTrackMenu()

	if LibDBIcon10_TownsfolkTracker then
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("OVERLAY")
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("BACKGROUND")
	end
end