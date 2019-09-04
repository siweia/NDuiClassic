﻿local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Maps")

local strmatch, strfind, strupper = string.match, string.find, string.upper
local select, pairs, ipairs, unpack = select, pairs, ipairs, unpack
local cr, cg, cb = DB.r, DB.g, DB.b

function module:CreatePulse()
	if not NDuiDB["Map"]["CombatPulse"] then return end

	local MBG = B.CreateBG(Minimap, 1)
	B.CreateSD(MBG)
	local anim = MBG:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(.8)
	anim.fader:SetToAlpha(.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapAnim(event)
		if event == "PLAYER_REGEN_DISABLED" then
			MBG.Shadow:SetBackdropBorderColor(1, 0, 0)
			anim:Play()
		elseif not InCombatLockdown() then
			if MiniMapMailFrame:IsShown() then
				MBG.Shadow:SetBackdropBorderColor(1, 1, 0)
				anim:Play()
			else
				anim:Stop()
				MBG.Shadow:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
	B:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapAnim)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapAnim)
	B:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapAnim)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then return end
		anim:Stop()
		MBG.Shadow:SetBackdropBorderColor(0, 0, 0)
	end)
end

function module:ReskinRegions()
	-- Tracking icon
	MiniMapTrackingFrame:SetScale(.7)
	MiniMapTrackingFrame:ClearAllPoints()
	MiniMapTrackingFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 5)
	MiniMapTrackingBorder:Hide()
	MiniMapTrackingIcon:SetTexCoord(unpack(DB.TexCoord))
	local bg = B.CreateBG(MiniMapTrackingIcon)
	B.CreateBD(bg)
	bg:SetBackdropBorderColor(cr, cg, cb)

	-- Mail icon
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
	MiniMapMailIcon:SetTexture(DB.mailTex)
	MiniMapMailIcon:SetSize(21, 21)
	MiniMapMailIcon:SetVertexColor(1, 1, 0)
end

function module:RecycleBin()
	if not NDuiDB["Map"]["ShowRecycleBin"] then return end

	local buttons = {}
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

	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("RIGHT", bu, "LEFT", -3, -6)
	bin:Hide()
	B.CreateGF(bin, 220, 40, "Horizontal", 0, 0, 0, 0, .7)
	local topLine = CreateFrame("Frame", nil, bin)
	topLine:SetPoint("BOTTOMRIGHT", bin, "TOPRIGHT", 1, 0)
	B.CreateGF(topLine, 220, 1, "Horizontal", cr, cg, cb, 0, .7)
	local bottomLine = CreateFrame("Frame", nil, bin)
	bottomLine:SetPoint("TOPRIGHT", bin, "BOTTOMRIGHT", 1, 0)
	B.CreateGF(bottomLine, 220, 1, "Horizontal", cr, cg, cb, 0, .7)
	local rightLine = CreateFrame("Frame", nil, bin)
	rightLine:SetPoint("LEFT", bin, "RIGHT", 0, 0)
	B.CreateGF(rightLine, 1, 40, "Vertical", cr, cg, cb, .7, .7)
	bin:SetFrameStrata("LOW")

	local function hideBinButton()
		bin:Hide()
	end
	local function clickFunc()
		UIFrameFadeOut(bin, .5, 1, 0)
		C_Timer.After(.5, hideBinButton)
	end

	local function CollectRubbish()
		for _, child in ipairs({Minimap:GetChildren()}) do
			local name = child:GetName()
			if name and not blackList[name] and not strmatch(strupper(name), "HANDYNOTES") and not strmatch(strupper(name), "GUIDELIME") then
				if child:GetObjectType() == "Button" or strmatch(strupper(name), "BUTTON") then
					child:SetParent(bin)
					child:SetSize(34, 34)
					for j = 1, child:GetNumRegions() do
						local region = select(j, child:GetRegions())
						if region:GetObjectType() == "Texture" then
							local texture = region:GetTexture() or ""
							if strfind(texture, "Interface\\CharacterFrame") or strfind(texture, "Interface\\Minimap") then
								region:SetTexture(nil)
							elseif texture == 136430 or texture == 136467 then
								region:SetTexture(nil)
							end
							region:ClearAllPoints()
							region:SetAllPoints()
							region:SetTexCoord(unpack(DB.TexCoord))
						end
					end

					if child:HasScript("OnDragStart") then child:SetScript("OnDragStart", nil) end
					if child:HasScript("OnDragStop") then child:SetScript("OnDragStop", nil) end
					if child:HasScript("OnClick") then child:HookScript("OnClick", clickFunc) end

					if child:GetObjectType() == "Button" then
						child:SetHighlightTexture(DB.bdTex) -- prevent nil function
						child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					elseif child:GetObjectType() == "Frame" then
						child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
						child.highlight:SetAllPoints()
						child.highlight:SetColorTexture(1, 1, 1, .25)
					end
					B.CreateSD(child, 3, 3)

					-- Naughty Addons
					if name == "DBMMinimapButton" then
						child:SetScript("OnMouseDown", nil)
						child:SetScript("OnMouseUp", nil)
					elseif name == "BagSync_MinimapButton" then
						child:HookScript("OnMouseUp", clickFunc)
					end

					tinsert(buttons, child)
				end
			end
		end
	end

	local function SortRubbish()
		if #buttons == 0 then return end
		local lastbutton
		for _, button in pairs(buttons) do
			if button:IsShown() then
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

	C_Timer.After(.3, function()
		CollectRubbish()
		SortRubbish()
	end)
end

function module:WhoPingsMyMap()
	if not NDuiDB["Map"]["WhoPings"] then return end

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
	local scale = NDuiDB["Map"]["MinmapScale"]
	Minimap:SetScale(scale)
	Minimap.mover:SetSize(Minimap:GetWidth()*scale, Minimap:GetHeight()*scale)
end

function module:ShowMinimapClock()
	if NDuiDB["Map"]["Clock"] then
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

function module:SetupMinimap()
	-- Shape and Position
	local scale = NDuiDB["Map"]["MinmapScale"]
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
		--"MiniMapTracking",
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
end
