local btn = CreateFrame("Button", "TranscribeButton", ItemTextFrame, "UIPanelButtonTemplate")
btn:SetWidth(100)
btn:SetHeight(25)
btn:SetText("Transcribe")
btn:SetPoint("BOTTOMRIGHT", ItemTextFrame, "BOTTOMRIGHT", -61, 76)
btn:Show()

local function goToFirstPage()
    while ItemTextGetPage() > 1 do
        ItemTextPrevPage()
    end
end

local function scanItemText()
    while ItemTextHasNextPage() do
       local pageContent = ItemTextGetText()
       print(pageContent)
       ItemTextNextPage()
    end
end

local function returnToInitialPage(initialPage)
    while ItemTextGetPage() > initialPage do
        ItemTextPrevPage()
    end
end

btn:SetScript("OnClick", function()
    local initialPage = ItemTextGetPage()
    local title = ItemTextGetItem()
    print(title)

    goToFirstPage()

    scanItemText()

    returnToInitialPage(initialPage)
end)

