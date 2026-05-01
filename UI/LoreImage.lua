local loreImages = {
    "INV_Misc_Book_1",
    "INV_Misc_Book_2",
    "INV_Misc_Book_3",
    "INV_Misc_Book_4",
    "INV_Misc_Book_5",
    "INV_Misc_Book_6",
    "INV_Misc_Book_7",
    "INV_Misc_Book_8",
    "INV_Misc_Book_9",
    "INV_Misc_Book_10",
    "INV_Misc_Book_11",
    "INV_Misc_Book_12",
    "INV_Misc_Book_13",
    "INV_Misc_Book_14",
    "INV_Misc_Book_15"
}

local function hashFn(key)
    local hash = 0

    for i = 1, #key do
        hash = hash * 31 + string.byte(key, i)
    end

    return hash % #loreImages
end

function LoreKeeper_GetLoreImage(title)
    local index = hashFn(title)

    return loreImages[index]
end