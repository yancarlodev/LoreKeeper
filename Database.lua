LoreKeeperDatabase = LoreKeeperDatabase or {
    Lore = {}
}

LoreKeeperLoreRepo = {}

function LoreKeeperLoreRepo:Save(lore)
    if LoreKeeperDatabase['Lore'][lore.title] ~= nil then
        return
    end

    LoreKeeperDatabase['Lore'][lore.title] = lore
end

function LoreKeeperLoreRepo:Update(title, lore)
    if LoreKeeperDatabase['Lore'][title] == nil then
        return
    end

    for key, value in pairs(lore) do
        LoreKeeperDatabase['Lore'][title][key] = value
    end
end

function LoreKeeperLoreRepo:Get(title)
    if LoreKeeperDatabase['Lore'][title] == nil then
        return
    end

    return LoreKeeperDatabase['Lore'][title]
end