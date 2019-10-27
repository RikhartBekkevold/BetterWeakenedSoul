local x = 0;
local y = -150;
local width = 50;
local height = 50;

local btn = CreateFrame("Button", "", UIParent)
btn:SetSize(width, height)
btn:SetPoint("CENTER", UIParent, "CENTER", x, y)
btn:SetNormalTexture("")

local cd = CreateFrame("Cooldown", "", btn, "CooldownFrameTemplate")
cd:SetPoint("TOPLEFT", btn, "TOPLEFT")
cd:SetSize(width, height)
cd:SetReverse(true)


function addIcon()
    local i = 1;
    local auraname, auraicon, count, debuffType, duration, expirationTime = UnitDebuff("player", i);

    while auraname do

        if auraname == "Weakened Soul" then
            btn:SetNormalTexture(auraicon)
            -- add cooldown animnation
            if duration > 0 then
                local time_completed = duration - (expirationTime - GetTime())
                cd:SetCooldown(GetTime() - time_completed, duration)
            end
        end

        i = i + 1;
        auraname, auraicon, count, debuffType, duration, expirationTime = UnitDebuff("player", i);
    end
end


function removeIcon()
    btn:SetNormalTexture("")
    cd:SetDrawBling(false)
    cd:SetCooldown(0, 0)
end


btn:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    -- if an aura has changed (added, removed)..
    if event == "UNIT_AURA" then
        -- ..on the player
        if arg1 == "player" then
            removeIcon()
            addIcon()
        end
    end
end)

btn:RegisterEvent("UNIT_AURA")
