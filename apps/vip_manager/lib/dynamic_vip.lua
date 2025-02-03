-- 当前方案中缺少IP地址冲突检测机制
local function allocate_vip(pool)
    -- 需要增加ARP检测逻辑
    if arp_check(vip) then
        error("VIP冲突: "..vip)
    end
end 