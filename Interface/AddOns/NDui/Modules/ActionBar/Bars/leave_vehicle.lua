local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.leave_vehicle

function Bar:CreateLeaveVehicle()
	local padding, margin = 10, 5
	local num = 1
	local buttonList = {}

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent)
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	if NDuiDB["Actionbar"]["Style"] == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 130}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 320, 100}
	end

	--the button
	local button = CreateFrame("Button", "NDui_LeaveVehicleButton", frame)
	table.insert(buttonList, button) --add the button object to the list
	button:SetSize(cfg.size, cfg.size)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")
	B.PixelIcon(button, "INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up", true)
	button.Icon:SetTexCoord(.216, .784, .216, .784)
	B.CreateSD(button)

	local function updateVisibility()
		if UnitOnTaxi("player") then
			button:Show()
		else
			button:Hide()
			button:UnlockHighlight()
		end
	end
	hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", updateVisibility)

	local function onClick(self)
		if not UnitOnTaxi("player") then return end
		TaxiRequestEarlyLanding()
		self:LockHighlight()
	end
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end