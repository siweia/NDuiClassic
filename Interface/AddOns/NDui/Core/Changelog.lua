local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"DBM美化更新；",
	"技能监控列表调整；",
	"公会银行添加物品品质染色；",
	"优化头像连击点的刷新；",
	"头像的血量及能量的标签调整；",
	"优化施法条的法术目标的刷新；",
	"自动攻击计时条调整；",
	"治疗预估更新；",
	"右键菜单的交互色块调整；",
	"目标死亡时不再隐藏鼠标提示的状态条；",
	"可以按住ALT并点击NPC窗口名称屏蔽其自动交互；",
	"BaudErrorFrame更新；",
	"更新记录面板调整；",
	"姓名板添加友方姓名板独立设置选项；",
	"姓名板的稀有度指示器的位置调整；",
	"优化姓名板的相关选项，支持更多自定义；",
	"信息条现在可以自由排列组合；",
	"背包整理更新；",
	"背包选项优化，大部分可以即使刷新；",
	"背包添加每列排序数量的选项；",
	"动作条的相关选项调整；",
	"动作条支持自定义，并与他人分享布局；",
	"按住shift指向目标时显示与你的声望状态；",
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