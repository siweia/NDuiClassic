local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新BaudErrorFrame；",
	"更新副本内聊天气泡材质；",
	"修正团队框体的队伍标签；",
	"关闭延迟数值将关闭施法条延迟显示；",
	"界面美化更新；",
	"DBM美化微调；",
	"背包整理更新；",
	"修正从正式服转移数据时的一个错误；",
	"重做微型菜单使其可以战斗中打开；",
	"打开帮助面板时如果开启语言过滤器会进行提示；",
	"修正德鲁伊树人形态与额外动作条冲突的问题；",
	"动作条添加已装备物品染色，默认关闭；",
	"修复LibHealComm牧师T4法术的冲突问题；",
	"添加竞技场框体(未测试)；",
	"重新添加韩语文本；",
	"修正打断等通报的错误；",
	"专业标签支持珠宝；",
	"角色属性面板模型调整；",
	"自动攻击计时条调整；",
	"优化信息条好友模块的显示；",
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