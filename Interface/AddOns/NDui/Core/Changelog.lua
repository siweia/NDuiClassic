local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"由TBC版本移植，更新支持1.14.0；",
	"动作条添加已装备物品染色，默认关闭；",
	"动作条添加猎人守护条；",
	"背包菜单栏优化；",
	"背包添加分组排序功能，默认关闭；",
	"团队框体添加增益及减益指示器；",
	"团队减益现在按照副本进行分组；",
	"姓名板添加法术目标显示，默认关闭；",
	"姓名板添加重要法术高亮；",
	"添加锁定目标姓名板功能；",
	"拆分打断及驱散通报，并添加受控通报，默认关闭；",
	"添加选项以关闭谜语提示音；",
	"小地图添加尺寸条件；",
	"小地图添加副本难度旗帜；",
	"界面美化更新；",
	"优化对CharacterStatsClassic的美化；",
	"优化邮箱工具，支持保存上一次收件人；",
	"添加快捷菜单按钮；",
	"添加猎人宠物忠诚度提示；",
	"治疗预估更新，LHC现在只负责hot类法术。",
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