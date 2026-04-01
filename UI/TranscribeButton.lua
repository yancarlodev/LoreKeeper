local btn = CreateFrame("Button", "TranscribeButton", ItemTextFrame, "UIPanelButtonTemplate")
btn:SetWidth(100)
btn:SetHeight(25)
btn:SetText("Transcribe")
btn:SetPoint("BOTTOMRIGHT", ItemTextFrame, "BOTTOMRIGHT", -61, 76)
btn:Show()

local function goToPage(page)
    if page > ItemTextGetPage() then
        while ItemTextGetPage() < page do
            ItemTextNextPage()
        end

        return
    end

    while ItemTextGetPage() > page do
        ItemTextPrevPage()
    end
end

local function scanItemText()
    local pages = {}

    while ItemTextHasNextPage() do
       local pageContent = ItemTextGetText()
       table.insert(pages, pageContent)
       ItemTextNextPage()
    end

    return pages
end

local function transcribeLore()
    local initialPage = ItemTextGetPage()

    goToPage(1)

    local title = ItemTextGetItem()
    local pages = scanItemText()

    LoreKeeperLoreRepo:Save({
        title = title,
        bookmark = initialPage,
        pages = pages
    })

    goToPage(initialPage)
end

btn:SetScript("OnClick", transcribeLore)

local function goToBookmark()
    local title = ItemTextGetItem()

    local lore = LoreKeeperLoreRepo:Get(title)

    if lore == nil then return end

    goToPage(lore.bookmark)
end

btn:SetScript("onShow", goToBookmark)

local function saveBookmark()
    local title = ItemTextGetItem()
    local currentPage = ItemTextGetPage()

    LoreKeeperLoreRepo:Update(title, {
        bookmark = currentPage
    })
end

btn:SetScript("onHide", saveBookmark)

