-- EzSort: static data.
local _, ns = ...

ns.ICON = "Interface\\Icons\\INV_Misc_Bag_08"

-- Bag frames the sort button can attach to; the first one that exists and is shown wins.
ns.BAG_FRAMES = { "ContainerFrameCombinedBags", "ContainerFrame1" }

ns.BINDINGS = {
    { action = "EZSORT_BAGS", label = "Sort bags" },
    { action = "EZSORT_BANK", label = "Sort bank" },
    { action = "EZSORT_REVERSE", label = "Flip sort direction" },
}

ns.HELP = {
    "/ezs - sort bags",
    "/ezs bank - sort bank (bank must be open)",
    "/ezs reverse - flip sort direction (left-to-right / right-to-left)",
    "/ezs loot - flip where new items go (backpack / leftmost bag first)",
    "/ezs button - show or hide the sort button on your bags",
}
