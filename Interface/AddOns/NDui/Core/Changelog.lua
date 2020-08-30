local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正战士怒吼技能的缺失提示；",
	"更新LCC和LCD；",
	"冬泉谷魂能道具相关归类为消耗品；",
	"背包图标元素更新；",
	"添加选项以调整姓名板法术过滤；",
	"个人资源条及其选项更新；",
	"更新部分技能监控；",
	"Buff框体微调；",
	"Details及部分界面美化微调；",
	"移除宝石相关信息；",
	"修正目标框体的能量值偏移；",
	"添加友方姓名板名字模式，默认关闭；",
	"头像的团队标记位置调整；",
	"添加选项以调整目标框体的每行法术图标数量；",
	"部分箭头及关闭按钮的材质更新；",
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
	B.CreateFS(f, 36, "|cff0080ffNDui|rClassic", true, "TOPLEFT", 10, 32)
	B.CreateFS(f, 16, DB.Version, true, "TOPRIGHT", -10, 16)
	B.CreateFS(f, 18, L["Changelog"], true, "TOP", 0, -10)
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
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 24
	end
	f:SetSize(480, 60 + offset)
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