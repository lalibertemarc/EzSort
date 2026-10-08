-- EzSort: one click to sort your bags and bank, either direction.
local _, ns = ...

local bankOpen = false

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffEzSort|r: " .. msg)
end

---------------------------------------------------------------------------
-- API compat (C_Container first, old globals as fallback)
---------------------------------------------------------------------------
local Container = C_Container or {}

local function Call(name, ...)
    local fn = Container[name] or _G[name]
    if fn then return true, fn(...) end
    return false
end

local function SortBankApi()
    if Container.SortBankBags or _G.SortBankBags then return Call("SortBankBags") end
    -- Mainline replaced SortBankBags with a per-bank-type call.
    if Container.SortBank and Enum and Enum.BankType then
        Container.SortBank(Enum.BankType.Character)
        return true
    end
    return false
end

local function RightToLeft()
    local _, v = Call("GetSortBagsRightToLeft")
    return v and true or false
end

local function DirectionText()
    return RightToLeft() and "right-to-left" or "left-to-right"
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------
local function CanSort()
    if InCombatLockdown() then
        Print("Can't sort in combat.")
        return false
    end
    return true
end

function EzSort_SortBags()
    if not CanSort() then return end
    if not Call("SortBags") then Print("Sorting isn't available in this client.") end
end

function EzSort_SortBank()
    if not CanSort() then return end
    if not bankOpen then return Print("Open your bank first.") end
    if not SortBankApi() then Print("Bank sorting isn't available in this client.") end
end

function EzSort_ToggleDirection()
    if not Call("SetSortBagsRightToLeft", not RightToLeft()) then
        return Print("Sort direction can't be changed in this client.")
    end
    Print("Sorting " .. DirectionText() .. ".")
end

local function ToggleLoot()
    local ok, leftToRight = Call("GetInsertItemsLeftToRight")
    if not ok or not Call("SetInsertItemsLeftToRight", not leftToRight) then
        return Print("Loot direction can't be changed in this client.")
    end
    Print(leftToRight and "New items go to your backpack first." or "New items go to your leftmost bag first.")
end

for _, binding in ipairs(ns.BINDINGS) do
    _G["BINDING_NAME_" .. binding.action] = binding.label
end
BINDING_HEADER_EZSORT = "EzSort"

---------------------------------------------------------------------------
-- Sort button on the bag frame
---------------------------------------------------------------------------
local button = CreateFrame("Button", "EzSortButton", UIParent)
button:SetSize(28, 28)
button:SetFrameStrata("HIGH")
button:Hide()
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
icon:SetTexture(ns.ICON)
button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("EzSort")
    GameTooltip:AddLine("Left-click: sort bags", 1, 1, 1)
    if bankOpen then GameTooltip:AddLine("Shift-click: sort bank", 1, 1, 1) end
    GameTooltip:AddLine("Right-click: flip direction", 1, 1, 1)
    GameTooltip:AddLine("Sorting " .. DirectionText(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
end

button:SetScript("OnEnter", ShowTooltip)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)
button:SetScript("OnClick", function(self, mouse)
    if mouse == "RightButton" then
        EzSort_ToggleDirection()
    elseif IsShiftKeyDown() then
        EzSort_SortBank()
    else
        EzSort_SortBags()
    end
    if GameTooltip:IsOwned(self) then ShowTooltip(self) end
end)

-- Parks the button just outside the top-left corner of whichever bag frame is open.
local function UpdateButton()
    button:Hide()
    if EzSortDB and EzSortDB.hideButton then return end
    for _, name in ipairs(ns.BAG_FRAMES) do
        local frame = _G[name]
        if frame and frame:IsShown() then
            button:ClearAllPoints()
            button:SetPoint("TOPRIGHT", frame, "TOPLEFT", -2, -4)
            button:Show()
            return
        end
    end
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
local COMMANDS = {
    [""]    = EzSort_SortBags,
    bank    = EzSort_SortBank,
    reverse = EzSort_ToggleDirection,
    loot    = ToggleLoot,
    button  = function()
        EzSortDB.hideButton = not EzSortDB.hideButton
        Print(EzSortDB.hideButton and "Sort button hidden." or "Sort button shown.")
        UpdateButton()
    end,
}

SLASH_EZSORT1 = "/ezs"
SLASH_EZSORT2 = "/ezsort"
SlashCmdList.EZSORT = function(msg)
    local fn = COMMANDS[strtrim(msg):lower()]
    if fn then
        fn()
    else
        for _, line in ipairs(ns.HELP) do Print(line) end
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("BANKFRAME_OPENED")
ev:RegisterEvent("BANKFRAME_CLOSED")
ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        EzSortDB = EzSortDB or {}
        for _, name in ipairs(ns.BAG_FRAMES) do
            local frame = _G[name]
            if frame then
                frame:HookScript("OnShow", UpdateButton)
                frame:HookScript("OnHide", UpdateButton)
            end
        end
    elseif event == "BANKFRAME_OPENED" then
        bankOpen = true
    elseif event == "BANKFRAME_CLOSED" then
        bankOpen = false
    end
end)
