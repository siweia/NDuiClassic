local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正珠宝饰品不显示装等的问题；",
	"界面美化更新；",
	"DBM默认设置调整；",
	"当减益不属于任何类型时，现在以黑色边框显示；",
	"角色属性展开的方式调整；",
	"修正边角指示器的计数异常；",
	"LibHealComm更新到v94；",
	"邮箱助手调整，联系人现在以服务器排序；",
	"菜单交互色块支持好友及公会列表；",
	"优化飞行点自动下马的方式；",
	"更新部分团本减益；",
	"调整小地图回收站的排序；",
	"修正控制台数据的转移；",
	"现在可以关闭指定施法条；",
	"由于很多人不会写宏，快速施法改成释放ID相应等级的法术；",
	"优化聊天窗口的快捷栏；",
	"小地图添加副本难度提示；",
	"拆分打断和驱散的相关选项；",
	"修正ExRT改名后的药水检查功能；",
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