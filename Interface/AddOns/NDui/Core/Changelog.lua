local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正LCD加载顺序的问题；",
	"更新LibHealComm；",
	"重新添加动作条物品计数；",
	"界面美化更新支持1.14.1；",
	"修正观察目标时简中客户端的报错；",
	"BaudErrorFrame支持对中文wa报错的捕捉；",
	"治疗预估更新，修正hot延迟的问题；",
	"目标死亡后不再隐藏鼠标提示的状态条；",
	"按住ALT点击对话窗口的NPC名字可屏蔽不再自动交接任务；",
	"更新日记面板的版本显示调整；",
	"单位框体的数值标签更新；",
	"添加独立设置友方姓名板尺寸的选项；",
	"背包整理更新；",
	"微型菜单更新，旧的地图按钮替换为查找器；",
	"给信息条添加部分选项，使其可以任意组合及移动；",
	"背包选项优化，大部分不再需要RL；",
	"背包添加每列排序数量的选项；",
	"姓名板的稀有指示器调整；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	local majorVersion = gsub(DB.Version, "%.%d+$", ".0")

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, majorVersion.." "..L["Changelog"], true, "TOP", 0, -10)
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