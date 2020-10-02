local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:RegisterModule("Actionbar")

local _G = _G
local tinsert, next = tinsert, next
local GetActionTexture = GetActionTexture
local cfg = C.Bars.bar1
local margin, padding = C.Bars.margin, C.Bars.padding

local function UpdateActionbarScale(bar)
	local frame = _G["NDui_Action"..bar]
	if not frame then return end

	local size = frame.buttonSize * NDuiDB["Actionbar"]["Scale"]
	frame:SetFrameSize(size)
	for _, button in pairs(frame.buttonList) do
		button:SetSize(size, size)
	end
end

function Bar:UpdateAllScale()
	if not NDuiDB["Actionbar"]["Enable"] then return end

	UpdateActionbarScale("Bar1")
	UpdateActionbarScale("Bar2")
	UpdateActionbarScale("Bar3")
	UpdateActionbarScale("Bar4")
	UpdateActionbarScale("Bar5")

	UpdateActionbarScale("BarExit")
	UpdateActionbarScale("BarPet")
	UpdateActionbarScale("BarStance")
end

local REAGENTS_STRING = gsub(SPELL_REAGENTS, HEADER_COLON.."(.+)", "").."(.+)"

function Bar:GetActionCount(action)
	B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
	B.ScanTip:SetAction(action)
	for i = 1, B.ScanTip:NumLines() do
		local line = _G["NDui_ScanTooltipTextLeft"..i]
		if not line then break end
		local text = line:GetText()
		local itemName = text and strmatch(text, REAGENTS_STRING)
		if itemName then
			itemName = itemName:gsub(":", "")
            		itemName = itemName:match("^%s*(.+)")
			return GetItemCount(itemName)
		end
	end
end

function Bar:FixActionCount()
	local action = self.action
	local texture = GetActionTexture(action)
	if not texture then return end

	if not IsItemAction(action) and GetActionCount(action) == 0 then
		local count = Bar:GetActionCount(action)
		if count then
			if count > 999 then
				self.Count:SetText("*")
			else
				self.Count:SetText(count)
			end
		end
	end
end

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, L["Main Actionbar"], "Bar1", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateBar1()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	local frame = CreateFrame("Frame", "NDui_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	if layout == 5 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -108, 24}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 24}
	end

	for i = 1, num do
		local button = _G["ActionButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
		button:SetParent(frame)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["ActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	local actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	local buttonName = "ActionButton"
	for i, button in next, buttonList do
		frame:SetFrameRef(buttonName..i, button)
	end

	frame:Execute(([[
		buttons = table.new()
		for i = 1, %d do
			tinsert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(num, buttonName))

	frame:SetAttribute("_onstate-page", [[
		for _, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]])
	RegisterStateDriver(frame, "page", actionPage)

	-- Credit: ShowActionCount, prozhong
	hooksecurefunc("ActionButton_UpdateCount", self.FixActionCount)
end

function Bar:OnLogin()
	Bar.buttons = {}
	Bar:MicroMenu()

	if not NDuiDB["Actionbar"]["Enable"] then return end

	Bar:CreateBar1()
	Bar:CreateBar2()
	Bar:CreateBar3()
	Bar:CreateBar4()
	Bar:CreateBar5()
	Bar:CustomBar()
	Bar:CreateLeaveVehicle()
	Bar:CreatePetbar()
	Bar:CreateStancebar()
	Bar:HideBlizz()
	Bar:ReskinBars()
	Bar:UpdateAllScale()
end 
