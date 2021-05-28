local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinEventTraceButton(button)
	B.Reskin(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function reskinScrollArrow(self, direction)
	self.Texture:SetAlpha(0)
	self.Overlay:SetAlpha(0)
	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	B.CreateBDFrame(tex, .25)
	B.SetupArrow(tex, direction)
	self.__texture = tex

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
end

local function reskinEventTraceScrollBar(scrollBar)
	B.StripTextures(scrollBar)
	scrollBar:DisableDrawLayer("BACKGROUND")
	reskinScrollArrow(scrollBar.Back, "up")
	reskinScrollArrow(scrollBar.Forward, "down")

	local thumb = scrollBar:GetThumb()
	B.StripTextures(thumb, 0)
	B.CreateGradient(B.CreateBDFrame(thumb, 0))
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local hideButton = child and child.HideButton
		if hideButton and not hideButton.styled then
			B.ReskinClose(hideButton)
			hideButton:ClearAllPoints()
			hideButton:SetPoint("LEFT", 3, 0)

			local checkButton = child.CheckButton
			if checkButton then
				B.ReskinCheck(checkButton)
				checkButton:SetSize(22, 22)
			end

			hideButton.styled = true
		end
	end
end

local function reskinEventTraceScrollBox(frame)
	frame:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(frame, .25)
	hooksecurefunc(frame, "Update", reskinScrollChild)
end

local function ReskinEventTraceFrame(frame)
	reskinEventTraceScrollBox(frame.ScrollBox)
	reskinEventTraceScrollBar(frame.ScrollBar)
end

-- Table Attribute Display
local function reskinTableAttribute(frame)
	if frame.styled then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinCheck(frame.VisibilityButton)
	B.ReskinCheck(frame.HighlightButton)
	B.ReskinCheck(frame.DynamicUpdateButton)
	B.ReskinInput(frame.FilterBox)

	B.ReskinArrow(frame.OpenParentButton, "up")
	B.ReskinArrow(frame.NavigateBackwardButton, "left")
	B.ReskinArrow(frame.NavigateForwardButton, "right")
	B.ReskinArrow(frame.DuplicateButton, "up")

	frame.NavigateBackwardButton:ClearAllPoints()
	frame.NavigateBackwardButton:SetPoint("LEFT", frame.OpenParentButton, "RIGHT")
	frame.NavigateForwardButton:ClearAllPoints()
	frame.NavigateForwardButton:SetPoint("LEFT", frame.NavigateBackwardButton, "RIGHT")
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT")

	B.StripTextures(frame.ScrollFrameArt)
	B.CreateBDFrame(frame.ScrollFrameArt, .25)
	B.ReskinScroll(frame.LinesScrollFrame.ScrollBar)

	frame.styled = true
end

C.themes["Blizzard_DebugTools"] = function()
	reskinTableAttribute(TableAttributeDisplay)
	hooksecurefunc(TableInspectorMixin, "InspectTable", reskinTableAttribute)

	-- EventTrace
	B.ReskinPortraitFrame(EventTrace)

	local subtitleBar = EventTrace.SubtitleBar
	B.ReskinFilterButton(subtitleBar.OptionsDropDown)

	local logBar = EventTrace.Log.Bar
	local filterBar = EventTrace.Filter.Bar
	B.ReskinEditBox(logBar.SearchBox)

	ReskinEventTraceFrame(EventTrace.Log.Events)
	ReskinEventTraceFrame(EventTrace.Log.Search)
	ReskinEventTraceFrame(EventTrace.Filter)

	local buttons = {
		subtitleBar.ViewLog,
		subtitleBar.ViewFilter,
		logBar.DiscardAllButton,
		logBar.PlaybackButton,
		logBar.MarkButton,
		filterBar.DiscardAllButton,
		filterBar.UncheckAllButton,
		filterBar.CheckAllButton,
	}
	for _, button in pairs(buttons) do
		ReskinEventTraceButton(button)
	end
end