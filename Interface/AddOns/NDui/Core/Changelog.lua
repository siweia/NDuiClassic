local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正启用竞技场框体没有隐藏系统竞技场框体的问题；",
	"修正部分UI缩放下动作条尺寸异常的问题；",
	"调整状态条平滑度选项的范围，为1则关闭；",
	"界面美化更新支持2.5.4；",
	"移除专业面板的搜索框；",
	"优化buff框体的性能；",
	"聊天复制调整；",
	"Details美化更新；",
	"小地图回收站右键可切换回收模式；",
	"自动攻击计时条不再依附于玩家施法条；",
	"修复因服务器延迟等原因导致信息条耐久度模块的报错；",
	"竞技场框体的施法条正确跟随尺寸调节，无需RL后变化；",
	"设置转移功能调整；",
	"姓名板稀有度指示器材质更新；",
	"姓名板目标指示器添加动效；",
	"姓名板名字模式的过滤调整，并添加更多选项；",
	"姓名板添加部分CVar控制选项；",
	"部分反馈的问题修正；",
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