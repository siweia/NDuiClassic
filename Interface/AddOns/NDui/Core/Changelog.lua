local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"技能监控更新；",
	"背包整理更新；",
	"UI缩放调整，防止重载后聊天窗口异位；",
	"界面美化更新，更多窗口添加物品品质染色；",
	"Bigwigs美化更新；",
	"技能监控自定义分组添加一个新的触发器；",
	"自动交接功能调整；",
	"在侧边属性栏及目标观察面板显示装等；",
	"修正地图队友标记显示问题；",
	"自动下坐骑功能只针对飞行管理员；",
	"焦点框体显示可驱散Buff；",
	"重制边角指示器列表；",
	"更新技能缺失提示，荆棘术及心灵之火仅在PVP环境提示；",
	"优化头像连击点的响应速度；",
	"添加猎人宠物状态提示信息；",
	"添加猎人姿态技能条；",
	"调整物品装等及售价的显示方式；",
	"优化启用字体阴影时的配方显示；",
	"右键菜单添加彩色按钮以便快速交互；",
	"标记背包内未被接受的任务道具，未测试；",
	"添加选项以保存上一次的收件人；",
	"专业面板支持搜索；",
	"专业快捷标签调整；",
	"聊天过滤更新；",
	"物品链接支持插槽信息显示；",
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