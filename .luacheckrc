std = "lua51"
max_line_length = false
self = false

globals = {
    "EzSortDB",
    "EzSort_SortBags",
    "EzSort_SortBank",
    "EzSort_ToggleDirection",
    "BINDING_HEADER_EZSORT",
    "SLASH_EZSORT1",
    "SLASH_EZSORT2",
    "SlashCmdList",
}

read_globals = {
    -- Lua / WoW utility
    "strtrim",
    -- Frames & UI
    "CreateFrame", "UIParent", "GameTooltip", "DEFAULT_CHAT_FRAME", "NORMAL_FONT_COLOR",
    -- Namespaced APIs
    "C_Container", "Enum",
    -- Global APIs
    "InCombatLockdown", "IsShiftKeyDown",
}
