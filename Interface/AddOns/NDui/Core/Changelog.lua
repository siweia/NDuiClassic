local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"施法条字号跟随头像字号缩放；",
	"更新头像的文本标签；",
	"团队框体调整；",
	"背包垃圾分类按钮更新，ALT+CTRL点击可重置自定义列表；",
	"修正背包物品鼠标提示的刷新；",
	"背包支持Pawn升级图标；",
	"暴雪默认背包的美化更新；",
	"邮箱联系人列表现在没有上限；",
	"邮箱重新添加收取金币等功能；",
	"添加不兼容的插件检测；",
	"更新LibHealComm和LCC；",
	"技能监控及其列表更新；",
	"技能缺失提示添加猎人强击光环及雄鹰守护；",
	"去除地图迷雾添加选项以移除阴影；",
	"启用alaCalendar时，鼠标中键点击地图可以开关；",
	"重构小地图回收站；",
	"控制台添加配置管理的功能；",
	"配置转移功能更新；",
	"修复姓名板任务指示器对Questie的支持；",
	"密语聊天的提示音频率调整；",
	"添加选项以发送动作条技能的冷却状态；",
	"微调自动售垃圾的速度；",
	"精简设置向导，添加部分帮助提示；",
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