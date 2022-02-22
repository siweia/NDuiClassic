local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local function SetupInstance(instance)
	if instance.styled then return end
	-- if window is hidden on init, show it and hide later
	if not instance.baseframe then
		instance:ShowWindow()
		instance.wasHidden = true
	end
	-- reset texture if using Details default texture
	local needReset = instance.row_info.texture == "BantoBar"

	instance:ChangeSkin("Minimalistic")
	instance:InstanceWallpaper(false)
	instance:DesaturateMenu(true)
	instance:HideMainIcon(false)
	instance:SetBackdropTexture("None") -- if block window from resizing, then back to "Details Ground", needs review
	instance:MenuAnchor(16, 3)
	instance:ToolbarMenuButtonsSize(1)
	instance:AttributeMenu(true, 0, 3, DB.Font[1], 13, {1, 1, 1}, 1, true)
	instance:SetBarSettings(needReset and 18, needReset and "normTex")
	instance:SetBarTextSettings(needReset and 14, DB.Font[1], nil, nil, nil, true, true)

	local bg = B.SetBD(instance.baseframe)
	bg:SetPoint("TOPLEFT", -1, 18)
	instance.baseframe.bg = bg

	if instance:GetId() <= 2 then
		local open, close = S:CreateToggle(instance.baseframe)
		open:HookScript("OnClick", function()
			instance:ShowWindow()
		end)
		close:HookScript("OnClick", function()
			instance:HideWindow()
		end)
		-- hide window if hidden on init
		if instance.wasHidden then
			close:Click()
		end
	end

	instance.styled = true
end

local function EmbedWindow(instance, x, y, width, height)
	if not instance.baseframe then return end
	instance.baseframe:ClearAllPoints()
	instance.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
	instance:SetSize(width, height)
	instance:SaveMainWindowPosition()
	instance:RestoreMainWindowPosition()
	instance:LockInstance(true)
end

local function ReskinDetails()
	if not C.db["Skins"]["Details"] then return end

	local Details = _G.Details
	-- instance table can be nil sometimes
	Details.tabela_instancias = Details.tabela_instancias or {}
	Details.instances_amount = Details.instances_amount or 5

	local index = 1
	local instance = Details:GetInstance(index)
	while instance do
		SetupInstance(instance)
		index = index + 1
		instance = Details:GetInstance(index)
	end

	-- Reanchor
	local instance1 = Details:GetInstance(1)
	local instance2 = Details:GetInstance(2)

	if NDuiADB["ResetDetails"] then
		local height = 190
		if instance1 then
			if instance2 then
				height = 96
				EmbedWindow(instance2, -3, 140, 320, height)
			end
			EmbedWindow(instance1, -3, 24, 320, height)
		end
	end

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			if not instance.styled and instance:GetId() == 2 then
				instance1:SetSize(320, 96)
				EmbedWindow(instance, -3, 140, 320, 96)
			end
			SetupInstance(instance)
		end
	end

	-- Numberize
	local current = NDuiADB["NumberFormat"]
	if current < 3 then
		Details.numerical_system = current
		Details:SelectNumericalSystem()
	end
	-- Reset to one window
	Details.OpenWelcomeWindow = function()
		if instance1 then
			EmbedWindow(instance1, -3, 24, 320, 190)
			instance1:SetBarSettings(18, "normTex")
			instance1:SetBarTextSettings(14, DB.Font[1], nil, nil, nil, true, true)
		end
	end

	NDuiADB["ResetDetails"] = false
end

S:RegisterSkin("Details", ReskinDetails)