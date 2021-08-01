local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 550 -- 风暴要塞

-- 奥
module:RegisterDebuff(TIER, INSTANCE, 0, 35383) -- 烈焰之地
module:RegisterDebuff(TIER, INSTANCE, 0, 35410) -- 融化护甲
-- 魔能机甲
module:RegisterDebuff(TIER, INSTANCE, 0, 34190) -- 奥术宝珠
-- 大星术师
module:RegisterDebuff(TIER, INSTANCE, 0, 33023) -- 索兰莉安印记
module:RegisterDebuff(TIER, INSTANCE, 0, 33044) -- 星术师之怒
module:RegisterDebuff(TIER, INSTANCE, 0, 33045) -- 星术师之怒
-- 凯尔萨斯·逐日者
module:RegisterDebuff(TIER, INSTANCE, 0, 36970) -- 奥术爆裂（星术师卡波妮娅）
module:RegisterDebuff(TIER, INSTANCE, 0, 37018) -- 燃烧（星术师卡波妮娅）
module:RegisterDebuff(TIER, INSTANCE, 0, 44863) -- 咆哮（萨古纳尔男爵）
module:RegisterDebuff(TIER, INSTANCE, 0, 37027) -- 遥控玩具（首席技师塔隆尼库斯）
module:RegisterDebuff(TIER, INSTANCE, 0, 36965) -- 撕裂（亵渎者萨拉德雷）
module:RegisterDebuff(TIER, INSTANCE, 0, 30225) -- 沉默（亵渎者萨拉德雷）
module:RegisterDebuff(TIER, INSTANCE, 0, 36834) -- 奥术干扰（凯尔萨斯·逐日者）
module:RegisterDebuff(TIER, INSTANCE, 0, 36797) -- 精神控制（凯尔萨斯·逐日者）