local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新各法术库；",
	"修正对LibTotemInfo的支持；",
	"添加背包堆叠物品快速拆分的功能；",
	"背包银行等背景色微调；",
	"添加邮件联系人列表的功能；",
	"UI缩放调整；",
	"点击施法中现在使用~来进行换行；",
	"背包选项调整时刷新状态；",
	"添加背包装备装等的阈值选项；",
	"BaudErrorFrame更新；",
	"小地图回收站微调，防止一些奇葩插件报错；",
	"添加伤害统计插件的皮肤开关的方向；",
	"禁用边角指示器后，使用其过滤显示buff；",
	"添加选项以缩放边角指示器和副本减益图标；",
	"边角指示器的模式切换即时生效；",
	"给团队等尺寸的调整添加独立窗口；",
	"团队工具根据位置自动调整展开方向；",
	"添加选项以屏蔽陌生人密语，默认关闭；",
	"Details美化更新；",
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