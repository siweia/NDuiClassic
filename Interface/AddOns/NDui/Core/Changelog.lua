local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新支持TBC怀旧服；",
	"移除失效无用的法术库；",
	"大量界面美化模块更新；",
	"界面美化添加灰色边框选项；",
	"添加焦点框体及其施法条；",
	"添加左键+点击快速设置焦点的功能；",
	"更新背包及银行模块；",
	"修正世界地图队友标记失效的问题；",
	"移除动作条物品计数（已内置）；",
	"更新部分技能监控；",
	"更新专业技能快捷标签；",
	"移除对CharacterStatsClassic的美化（已内置）；",
	"修正CLEU的相关功能；",
	"施法条引导跳数的法术列表更新；",
	"团队框体添加增益和减益指示器；",
	"团队框体添加单人时显示的选项；",
	"团队框体添加仅超员时切换团队选项；",
	"添加图腾计时条；",
	"微型菜单添加暴雪商城图标；",
	"姓名板更新，添加部分新选项；",
	"添加选项以调整目标标记的修饰键；",
	"背包整理按钮可供关闭，以防误触；",
	"角色及观察面板显示宝石信息；",
	"优化角色面板的信息显示；",
	"调整副本监控的结构；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, DB.Version.." "..L["Changelog"], true, "TOP", 0, -10)
	B.CreateWatermark(f)

	local ll = B.SetGradient(f, "H", .7, .7, .7, 0, .5, 100, C.mult)
	ll:SetPoint("TOP", -50, -35)
	local lr = B.SetGradient(f, "H", .7, .7, .7, .5, 0, 100, C.mult)
	lr:SetPoint("TOP", 50, -35)

	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 24
	end
	f:SetSize(480, 60 + offset)
	local close = B.CreateButton(f, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if NDui_Tutorial then return end

	local old1, old2 = strsplit(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = strsplit(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"