local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.leave_vehicle
local margin, padding = C.Bars.margin, C.Bars.padding

function Bar:CreateLeaveVehicle()
	local num = 1
	local size = cfg.size
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent)
	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", {"BOTTOM", UIParent, "BOTTOM", 320, 100})

	local button = CreateFrame("CheckButton", "NDui_LeaveVehicleButton", frame, "ActionButtonTemplate")
	tinsert(buttonList, button)
	button:SetSize(size, size)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(.216, .784, .216, .784)
	button.icon:SetDrawLayer("ARTWORK")
	button.icon.__lockdown = true

	hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", function()
		if UnitOnTaxi("player") then
			button:Show()
		else
			button:Hide()
			button:SetChecked(false)
		end
	end)

	button:SetScript("OnClick", function()
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end
		button:SetChecked(true)
	end)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)

	frame.buttons = buttonList

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end