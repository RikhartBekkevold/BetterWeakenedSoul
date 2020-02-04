local addonname, namespace = ...
SLASH_BWS1 = "/bwsreset"

local x = 0;
local y = 0;
local width = 50;
local height = 50;
local name = "BetterWeakenedSoul";
local WS_ICON = 135871;
local icon = 135871;
local btn1_text = "Lock position"
local canDrag = true;
local locked = false;
local showEffect = false;
local visible = false;
local debuffActive = false; -- this can be used for so much.. for example not redraw when event fires

local btn = CreateFrame("Button", name, UIParent)
btn:SetSize(width, height)
btn:SetPoint("CENTER", UIParent, "CENTER", x, y)
btn:SetNormalTexture(icon)
btn:SetMovable(true)
btn:EnableMouse(true)

local cd = CreateFrame("Cooldown", "", btn, "CooldownFrameTemplate")
cd:SetPoint("TOPLEFT", btn, "TOPLEFT")
cd:SetSize(width, height)
cd:SetReverse(true)
cd:SetDrawBling(showEffect) -- DB.showEffect

local Config_DropDownMenu = CreateFrame("Frame", "WSContextMenu", btn, "UIDropDownMenuTemplate")
Config_DropDownMenu:SetPoint("CENTER", btn, "CENTER")

local icon_size_slider = CreateFrame("Slider", "BWS_icon_size_slider", Config_DropDownMenu, "UIDropDownCustomMenuEntryTemplate, UnitPopupSliderTemplate")
icon_size_slider:SetOrientation('HORIZONTAL')
icon_size_slider:SetWidth(150)
icon_size_slider:SetHeight(17)
icon_size_slider:SetMinMaxValues(20, 100)

SlashCmdList["BWS"] = function(msg)
   visible = true
   btn:SetNormalTexture(135871)

   btn:ClearAllPoints()
   btn:SetPoint("CENTER", UIParent, "CENTER", x, y)

   width = 50
   height = 50
   btn:SetSize(width, height)
   BetterWeakenedSoulDB.width = width
   BetterWeakenedSoulDB.height = height

   -- update_DB() -- updates all
   icon_size_slider:SetValue(width)
end


local function addIcon()
    local i = 1;
    local auraname, auraicon, count, debuffType, duration, expirationTime = UnitDebuff("player", i);

    while auraname do

        if auraname == "Weakened Soul" then  -- and variable set WSApplied = false - then update - var = state tracking
            btn:SetNormalTexture(auraicon)
            debuffActive = true
            -- add cooldown animnation
            if duration > 0 then
                local time_completed = duration - (expirationTime - GetTime())
                cd:SetCooldown(GetTime() - time_completed, duration)
            end
            -- return if found debuff on player
            return
        end

        i = i + 1;
        auraname, auraicon, count, debuffType, duration, expirationTime = UnitDebuff("player", i);
    end

    -- will only reach this point if weakened soul was never found
    debuffActive = false

    -- when the debuff ends this func will run, and both conditions will be true
    if debuffActive == false and visible == false then
        btn:SetNormalTexture("")
        -- cd:SetCooldown(0, 0)
        BetterWeakenedSoulDB.visible = visible
    end
end


local function removeIcon()
    btn:SetNormalTexture("")
    cd:SetCooldown(0, 0)
end



btn:SetScript("OnEvent", function(self, event, arg1, arg2, arg3) -- this is where its passed, diff arg gets passed depending on what event caused the call - arg1 in unit aura is set as
    -- unit, while in addon loaded set as addon name of addon that was loaded - event is also passed so can tell which event
    -- if an aura has changed (added, removed)..
    if event == "UNIT_AURA" then
        -- ..on the player
        if arg1 == "player" then
            removeIcon()
            addIcon()
        end
    end

    -- this runs after global init above?
    if event == "ADDON_LOADED" then
        -- if not this addon being loaded
        if arg1 ~= name then return end

        if BetterWeakenedSoulDB == nil then
            BetterWeakenedSoulDB = {
                ["canDrag"] = true,
                ["locked"] = false,
                ["visible"] = false,
                ["btn1_text"] = "Lock position",
                ["width"] = 50,
                ["height"] = 50,
                ["showEffect"] = false
            }
        else
            -- when addon loaded, load every variable
            canDrag = BetterWeakenedSoulDB.canDrag
            locked = BetterWeakenedSoulDB.locked
            visible = BetterWeakenedSoulDB.visible
            btn1_text = BetterWeakenedSoulDB.btn1_text
            width = BetterWeakenedSoulDB.width
            height = BetterWeakenedSoulDB.height
            showEffect = BetterWeakenedSoulDB.showEffect
            -- use the vars to set the state of the icon
            btn:SetSize(width, height)
            cd:SetSize(width, height)
        end
    end
end)

-- inside: self:RegisterEvent("UNIT_AURA")
btn:RegisterEvent("UNIT_AURA")
btn:RegisterEvent("ADDON_LOADED")
-- btn:UnregisterEvent("ADDON_LOADED")


local function MenuOption_OnClick(self, arg1, arg2, checked)
    if locked and self:GetID() == 2 then
        btn1_text = "Unlock position"
        UIDropDownMenu_SetButtonText(1, 2, "Unlock position")
        locked = not locked
        canDrag = false
        BetterWeakenedSoulDB.btn1_text = btn1_text
        BetterWeakenedSoulDB.locked = locked
        BetterWeakenedSoulDB.canDrag = canDrag
    elseif not locked and self:GetID() == 2 then
        btn1_text = "Lock position"
        UIDropDownMenu_SetButtonText(1, 2, "Lock position")
        locked = not locked
        canDrag = true
        BetterWeakenedSoulDB.btn1_text = btn1_text
        BetterWeakenedSoulDB.locked = locked
        BetterWeakenedSoulDB.canDrag = canDrag
    end
end




-- runs everytime menu opens!!! so values get reset in menu each time
-- toggle menu calls init internally, init calls this internally
local function Config_DropDownMenu_OnLoad()

    info                = UIDropDownMenu_CreateInfo();
    info.text           = "Move Icon"
    info.notCheckable   = true;
    info.value          = "val321";
    info.isTitle        = true;
    UIDropDownMenu_AddButton(info);

    -- a title that changes val, not checked? -- icon?
    info            = UIDropDownMenu_CreateInfo();
    info.text       = btn1_text --"Lock frame"; -- set based on variable - so dont need set text
    info.value      = "val1";
    info.func       = MenuOption_OnClick -- handler is set here, the init function makes sure. so now there is an event handler set for it -- the args though. those 4 is paased
    info.checked    = locked
    info.notCheckable = true;
    info.tooltipOnButton = true
    info.tooltipTitle = "Lock position"  -- use variables of state "locked"-- use the value inside the title.. concat .. checked
    info.tooltipText = "Locks the icon in place, preventing it from being moved."
    info.keepShownOnClick = 1
    UIDropDownMenu_AddButton(info);


    UIDropDownMenu_AddSeparator(1)
    -------------------- 2 -----------------------------

    info            = UIDropDownMenu_CreateInfo();
    info.text       = "Visibility"
    info.value      = "val3312";
    info.isTitle = true;
    info.notCheckable = true;
    UIDropDownMenu_AddButton(info);

    info            = UIDropDownMenu_CreateInfo();
    info.text       = "Always visible"
    info.value      = "val222";
    info.func       = function(self, checked)
        -- if not already running / debuff active
        btn:SetNormalTexture(135871)
        visible = true
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0);
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)
    end
    info.checked    = visible
    info.tooltipOnButton = true
    info.tooltipTitle = "Visibility" -- must set title for tooltip to work -- use the value inside the title.. concat .. checked
    info.tooltipText = "Sets whether the icon is always visible, even if the debuff is not currently active."
    info.keepShownOnClick = 1
    UIDropDownMenu_AddButton(info);


    info            = UIDropDownMenu_CreateInfo();
    info.text       = "Only when debuff active"
    info.value      = "valhhh2";
    info.func       = function(self, checked)

        -- FIX THIS - also
        if not debuffActive then
            btn:SetNormalTexture("")
            BetterWeakenedSoulDB.visible = visible

        end

        visible = false
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0);
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)
    end
    info.checked    = not visible
    info.tooltipOnButton = true
    info.tooltipTitle = "Visibility" -- must set title for tooltip to work -- use the value inside the title.. concat .. checked
    info.tooltipText = "Sets whether the icon is always visible, even if the debuff is not currently active."
    info.keepShownOnClick = 1
    -- info.isNotRadio = true
    -- info.minWidth = 160
    UIDropDownMenu_AddButton(info);


    UIDropDownMenu_AddSeparator(1)
    ----------------- 3 --------------------


    info                = UIDropDownMenu_CreateInfo();
    info.text           = "Icon Size"
    info.value          = "val3";
    info.isTitle        = true;
    info.notCheckable   = true;
    UIDropDownMenu_AddButton(info);


    info = UIDropDownMenu_CreateInfo();
    info.customFrame = icon_size_slider
    info.value = "slider"
    info.customFrame:SetValue(width)
    info.keepShownOnClick = 1

    -- so many calls because hook?  when does a "value change"? test in retal version
    -- related to having two? only first time open menu though
    info.customFrame:SetScript("OnValueChanged", function(self)
        width = self:GetValue()     -- BetterWeakenedSoul.width = width = self:GetValue()
        height = self:GetValue() -- set "if BetterWeakenedSoul then" else dispaly "cant save now"
        BetterWeakenedSoulDB.width = width
        BetterWeakenedSoulDB.height = height
        btn:SetSize(BetterWeakenedSoulDB.width , BetterWeakenedSoulDB.height)

        if not visible and debuffActive then
            btn:SetNormalTexture(135871)
        end
    end)
    info.customFrame:SetScript("OnMouseUp", function(self)
        if not debuffActive and not visible then
            btn:SetNormalTexture("")
            visible = true
            BetterWeakenedSoulDB.visible = visible
        end
    end)
    UIDropDownMenu_AddButton(info);


    UIDropDownMenu_AddSeparator(1)
    ---------------- 4 ---------------------

    info            = UIDropDownMenu_CreateInfo();
    info.text       = "Display Flash Effect"
    info.value      = "val5";
    info.isTitle = true;
    info.notCheckable = true;
    UIDropDownMenu_AddButton(info);

    info            = UIDropDownMenu_CreateInfo();
    info.text       = "Yes"
    info.value      = "val6";
    info.tooltipOnButton = true
    info.tooltipTitle = "Flash when CD finish" -- must set title for tooltip to work -- use the value inside the title.. concat .. checked
    info.tooltipText = "Decides whether a flash effect occurs when cooldown ends (the same effect as the actionbar flash effect)."
    info.justifyH   = "CENTER"
    info.checked    = showEffect
    info.keepShownOnClick = 1
    info.func       = function()
        showEffect = true;
        cd:SetDrawBling(showEffect);
        BetterWeakenedSoulDB.showEffect = showEffect
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0);
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)
    end
    UIDropDownMenu_AddButton(info);


    info            = UIDropDownMenu_CreateInfo();
    info.text       = "No"
    info.value      = "val7";
    info.tooltipOnButton = true
    info.tooltipTitle = "Flash when CD finish" -- must set title for tooltip to work -- use the value inside the title.. concat .. checked
    info.tooltipText = "Decides whether a flash effect occurs when cooldown ends (the same effect as the actionbar flash effect)."
    info.justifyH   = "CENTER"
    info.checked    = not showEffect -- when they use same var one will be uncheck the other not, but only upon creation, force update?
    info.keepShownOnClick = 1
    info.func       = function()
        showEffect = false;
        cd:SetDrawBling(showEffect);
        BetterWeakenedSoulDB.showEffect = showEffect
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0);
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)
    end
    UIDropDownMenu_AddButton(info);

end

-- immidately visible when i enter the world

-- only apply the ones that arent active, because then they will be added to the end
-- https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.lua


        -- visible = true
        -- UIDropDownMenu_SetButtonText(1, 4, "Always visible")
        -- icon = 135871     icon = ""
        -- btn:SetNormalTexture(135871)   btn:SetNormalTexture("")
        -- BetterWeakenedSoulDB.visible = visible

UIDropDownMenu_Initialize(Config_DropDownMenu, Config_DropDownMenu_OnLoad, "MENU");
 -- removes slider bug
ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)


btn:SetScript("OnMouseDown", function(self, button)
    -- on left click, start dragging
    if button == "LeftButton" and not self.isMoving and canDrag then
        self:StartMoving();
        self.isMoving = true;
        btn:SetAlpha(0.5);
    end
    -- on right click, show dropdown menu
    if button == "RightButton" then
        ToggleDropDownMenu(1, nil, Config_DropDownMenu, btn, 0, 0)  --, _, _, 2);  delay not the same as global dela
    end
end)


btn:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
        btn:SetAlpha(1);
    end
end)


btn:SetScript("OnHide", function(self)
    if (self.isMoving) then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)
