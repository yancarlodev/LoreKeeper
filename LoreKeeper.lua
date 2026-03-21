local btn = CreateFrame("Button", nil, ItemTextFrame, "UIPanelButtonTemplate")
btn:SetWidth(100)
btn:SetHeight(25)
btn:SetText("Transcribe")
btn:SetPoint("BOTTOMRIGHT", ItemTextFrame, "BOTTOMRIGHT", -75, 90)

btn:Show()

btn:SetScript("OnClick", function()
    if ReadBook == nil then
        ReadBook = 0
    else
        ReadBook = ReadBook + 1
    end
    print(ReadBook)
    

    local currentPage = ItemTextGetPage()
    local title = ItemTextGetItem()
    print(title)

    while ItemTextGetPage() > 1 do
        ItemTextPrevPage()
    end

    while ItemTextHasNextPage() do
       local pageContent = ItemTextGetText()
       print(pageContent)
       ItemTextNextPage()
    end

    while ItemTextGetPage() > currentPage do
        ItemTextPrevPage()
    end
end)