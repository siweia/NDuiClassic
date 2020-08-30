local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.leave_vehicle
local margin, padding = C.Bars.margin, C.Bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateLeaveVehicle()
	local num = 1
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent)
	if NDuiDB["Actionbar"]["Style"] == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 130}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 320, 100}
	end

	local button = CreateFrame("Button", "NDui_LeaveVehicleButton", frame)
	tinsert(buttonList, button)
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

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end