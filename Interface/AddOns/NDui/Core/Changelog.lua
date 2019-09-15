local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新AuroraClassic；",
	"移除PremadeGroupsFilter的皮肤；",
	"启用LeatrixMaps时禁用去除迷雾功能；",
	"团队工具清理；",
	"更正鼠标提示对RealMobHealth的支持；",
	"战斗中不能再整理背包；",
	"添加选项以隐藏个人资源条的血条及能量条；",
	"更新姓名板的血量标签；",
	"更新LCD；",
	"更新设置向导，第一步不再可跳过；",
	"现在使用物品信息中的装备等级；",
	"任务面板拓展插件的美化更新；",
	"更新可驱散的职业列表；",
	"更新整理技能监控列表；",
	"技能监控现在支持法术的不同等级；",
	"修复职业技能缺失提醒；",
	"世界地图支持滚轮缩放；",
	"修复物品拾取框体的移动控制；",
	"姓名板添加目标为你时警示的伪仇恨功能；",
	"背包物品分类更新，添加自定义偏好模式；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.CreateBD(f)
	B.CreateSD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 26)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 14)
	B.CreateFS(f, 16, L["Changelog"], true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, f)
	ll:SetPoint("TOP", -50, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, f)
	lr:SetPoint("TOP", 50, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 12, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 20
	end
	f:SetSize(400, 60 + offset)
	local close = B.CreateButton(f, 16, 16, "X")
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