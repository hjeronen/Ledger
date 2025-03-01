--------------------------------------
-- LEDGERFRAME DEFINITIONS
--------------------------------------
local WINDOW_WIDTH = 380
local WINDOW_HEIGHT = 450
local PAGE_MARGIN_X = 50
local PAGE_MARGIN_Y = -60

local HEADER_FONT = "MORPHEUS"
local TEXT_FONT_OBJECT = "QuestFont"

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())

    local scrollChild = self:GetParent().ScrollFrame:GetScrollChild()
    if (scrollChild) then
        scrollChild:Hide()
    end

    self:GetParent().ScrollFrame:SetScrollChild(self.content)
    self.content:Show()
end


local function SetTabs(numTabs, ...)
    LedgerFrame.numTabs = numTabs
    local contents = {}
    local frameName = LedgerFrame:GetName()

    for i = 1, numTabs do
        local tab = CreateFrame("Button", frameName.."Tab"..i, LedgerFrame, "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(select(i, ...))
        tab:SetScript("OnClick", Tab_OnClick)

        tab.content = CreateFrame("Frame", nil, LedgerFrame.ScrollChild)
        tab.content:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
        tab.content:Hide()

        table.insert(contents, tab.content)

        if (i == 1) then
            tab:SetPoint("TOPLEFT", LedgerFrame, "BOTTOMLEFT", 5, 7)
        else
            tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -14, 0)
        end
    end

    Tab_OnClick(_G[frameName.."Tab1"])

    return unpack(contents) -- unpacks table (destructuring?)
end


local function CreateButton(point, relativeFrame, relativePoint, yOffset, text)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate")
	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
	btn:SetSize(140, 40)
	btn:SetText(text)
	btn:SetNormalFontObject("GameFontNormalLarge")
	btn:SetHighlightFontObject("GameFontHighlightLarge")
	return btn
end


local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20)
	
	if (newValue < 0) then
		newValue = 0
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange()
	end
	
	self:SetVerticalScroll(newValue)
end


local function CreateScrollFrame()
    local scrollFrame = CreateFrame("ScrollFrame", nil, LedgerFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(WINDOW_WIDTH - 17, WINDOW_HEIGHT - 27)
    scrollFrame:SetPoint("TOPLEFT", LedgerFrame, "TOPLEFT", 0, -27)
    scrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(WINDOW_WIDTH - 17, WINDOW_HEIGHT * 2)
    scrollFrame:SetScrollChild(scrollChild)

    local scrollBar = scrollFrame.ScrollBar
    scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)

    LedgerFrame.ScrollFrame = scrollFrame
    LedgerFrame.ScrollChild = scrollChild
end


local function CreateFontStringObject(frame)
    local LedgerText = frame:CreateFontString(nil, "OVERLAY", TEXT_FONT_OBJECT)
    LedgerText:SetFont("Fonts\\MORPHEUS.TTF", size or 16)
    return LedgerText
end


local function CreateFontStringObjectWithLedgerFont(frame, isHeader)
    if isHeader then
        return CreateFontStringObject(frame)
    end

    local LedgerText = frame:CreateFontString(nil, "OVERLAY", TEXT_FONT_OBJECT)
    return LedgerText
end


local function CreateTitle()
    local LedgerTitleFont = CreateFont("LedgerFont")
    LedgerTitleFont:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    local title = LedgerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	title:SetFontObject(LedgerTitleFont)
    title:SetTextColor(232/255, 225/255, 172/255)
	title:SetPoint("LEFT", LedgerFrameTitleBG, "LEFT", 6, 1)
	title:SetText("Ledger")
    return title
end


local function CreateSpace(relativeFrame, relativeObject)
    local space = relativeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    space:SetPoint("TOPLEFT", relativeObject, "BOTTOMLEFT", 0, -5)
    space:SetText("")
    return space
end


local function CreatePageHeader(page, text)
    local header = CreateFontStringObjectWithLedgerFont(page, true)
    header:SetPoint("TOPLEFT", page, "TOPLEFT", PAGE_MARGIN_X, PAGE_MARGIN_Y)
    header:SetText(text or "(no title)")
    return header
end


local function SuccessCountSetText(successCount)
    successCount:SetText("Successfully sold items: "..SuccessCount(LedgerData.items))
end

local function FailedCountSetText(failedCount)
    failedCount:SetText("Failed auctions (item count): "..FailedCount(LedgerData.items))
end

local function TotalMoneyEarnedSetText(totalMoneyEarned)
    totalMoneyEarned:SetText("Total money earned from auctions: "..ParseMoney(CountMoney(TotalMoneyCount(LedgerData.items))))
end

local function MostSoldItemSetText(element)
    local item = GetMostSoldItem()
    element:SetText(item.name.." ("..item.successfulAuctionsCount.." units sold)")
end

local function HighestUnitPriceSetText(element)
    local item = GetItemWithHighestUnitPrice()
    element:SetText(item.name.." ("..ParseMoney(CountMoney(item.highestSoldUnitPrice))..")")
end


local function IndexPageContent(indexPage)
    indexPage:SetPoint("TOPLEFT", indexPage:GetParent(), "TOPLEFT", 0, 0)
    indexPage:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)

    local header = CreatePageHeader(indexPage, "SUMMARY OF AUCTION DATA:")

    local successCount = CreateFontStringObjectWithLedgerFont(indexPage)
    successCount:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    SuccessCountSetText(successCount)
    local failedCount = CreateFontStringObjectWithLedgerFont(indexPage)
    failedCount:SetPoint("TOPLEFT", successCount, "BOTTOMLEFT", 0, -5)
    FailedCountSetText(failedCount)
    local totalMoneyEarned = CreateFontStringObjectWithLedgerFont(indexPage)
    totalMoneyEarned:SetPoint("TOPLEFT", failedCount, "BOTTOMLEFT", 0, -5)
    TotalMoneyEarnedSetText(totalMoneyEarned)

    local spacer = CreateSpace(indexPage, totalMoneyEarned)

    local mostSoldItemText = CreateFontStringObjectWithLedgerFont(indexPage)
    mostSoldItemText:SetPoint("TOPLEFT", spacer, "BOTTOMLEFT", 0, -5)
    mostSoldItemText:SetText("Most sold item:")
    local mostSoldItem = CreateFontStringObjectWithLedgerFont(indexPage)
    mostSoldItem:SetPoint("TOPLEFT", mostSoldItemText, "BOTTOMLEFT", 0, -5)
    MostSoldItemSetText(mostSoldItem)

    local spacerTwo = CreateSpace(indexPage, mostSoldItem)

    local highestUnitPriceText = CreateFontStringObjectWithLedgerFont(indexPage)
    highestUnitPriceText:SetPoint("TOPLEFT", spacerTwo, "BOTTOMLEFT", 0, -5)
    highestUnitPriceText:SetText("Highest unit price:")
    local highestUnitPrice = CreateFontStringObjectWithLedgerFont(indexPage)
    highestUnitPrice:SetPoint("TOPLEFT", highestUnitPriceText, "BOTTOMLEFT", 0, -5)
    HighestUnitPriceSetText(highestUnitPrice)


    indexPage.Header = header
    indexPage.SuccessCount = successCount
    indexPage.FailedCount = failedCount
    indexPage.TotalMoneyEarned = totalMoneyEarned
    indexPage.MostSoldItem = mostSoldItem
    indexPage.HighestUnitPrice = highestUnitPrice

    return indexPage
end

local function ClearItemsPage(itemsPage)
    for _, region in ipairs({itemsPage:GetRegions()}) do
        if region:GetObjectType() == "FontString" then
            region:SetText("")  -- Optional: Clear the text
        end
    end
end


local function ItemsPageSetItems(itemsPage)
    ClearItemsPage(itemsPage)

    local header = CreatePageHeader(itemsPage, "ITEM DATA:")

    local relativeText = header
    local startX = 0
    local totalHeight = 20

    local sortedItems = SortItemsByName(LedgerData.items)

    local contents = {}

    for _key, item in pairs(sortedItems) do

        local itemName = CreateFontStringObjectWithLedgerFont(itemsPage)
        itemName:SetPoint("TOPLEFT", relativeText, "BOTTOMLEFT", startX, -10)
        itemName:SetText(""..item.name)

        local successCount = CreateFontStringObjectWithLedgerFont(itemsPage)
        successCount:SetPoint("TOPLEFT", itemName, "BOTTOMLEFT", 10, -5)
        successCount:SetText("Successfully sold units: "..item.successfulAuctionsCount)

        local failedCount = CreateFontStringObjectWithLedgerFont(itemsPage)
        failedCount:SetPoint("TOPLEFT", successCount, "BOTTOMLEFT", 0, -5)
        failedCount:SetText("Failed sales units: "..item.failedAuctionsCount)

        local highestPrice = CreateFontStringObjectWithLedgerFont(itemsPage)
        highestPrice:SetPoint("TOPLEFT", failedCount, "BOTTOMLEFT", 0, -5)
        highestPrice:SetText("Highest unit price: "..ParseMoney(CountMoney(item.highestSoldUnitPrice)))

        local lowestPrice = CreateFontStringObjectWithLedgerFont(itemsPage)
        lowestPrice:SetPoint("TOPLEFT", highestPrice, "BOTTOMLEFT", 0, -5)
        lowestPrice:SetText("Lowest unit price: "..ParseMoney(CountMoney(item.lowestSoldUnitPrice)))

        local totalMoney = CreateFontStringObjectWithLedgerFont(itemsPage)
        totalMoney:SetPoint("TOPLEFT", lowestPrice, "BOTTOMLEFT", 0, -5)
        totalMoney:SetText("Total money earned: "..ParseMoney(CountMoney(item.totalMoneyEarned)))

        local spacer = CreateSpace(itemsPage, totalMoney)

        relativeText = spacer
        startX = -10
        totalHeight = totalHeight + 100
    end

    -- Dynamically adjust frame size
    totalHeight = totalHeight + 50
    itemsPage:SetHeight(totalHeight)

    return itemsPage
end


local function ItemsPageContent(itemsPage)
    itemsPage:SetPoint("TOPLEFT", itemsPage:GetParent(), "TOPLEFT", 0, 0)
    itemsPage:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)

    return ItemsPageSetItems(itemsPage)
end


local function SearchPage(searchPage)
    searchPage:SetPoint("TOPLEFT", itemsPage:GetParent(), "TOPLEFT", 0, 0)
    searchPage:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)

    CreatePageHeader(searchPage, "COMING SOON: ITEM SEARCH!")

    return searchPage
end


function UpdateLedger()
    SuccessCountSetText(LedgerFrame.indexPage.SuccessCount)
    FailedCountSetText(LedgerFrame.indexPage.FailedCount)
    TotalMoneyEarnedSetText(LedgerFrame.indexPage.TotalMoneyEarned)
    MostSoldItemSetText(LedgerFrame.indexPage.MostSoldItem)
    HighestUnitPriceSetText(LedgerFrame.indexPage.HighestUnitPrice)
    ItemsPageSetItems(LedgerFrame.itemsPage)
end


function InitializeLedgerFrame()
    LedgerPrint("Initializing LedgerFrame")
    
    LedgerFrame = CreateFrame("Frame", "LedgerFrame", UIParent, "UIPanelDialogTemplate")
    LedgerFrame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT + 8) -- width, height
    LedgerFrame:SetPoint("CENTER", UIParent, "CENTER") -- point, relativeFrame, relativePoint, xOffset, yOffset

    -----------------------------
    -- Textures
    -----------------------------

    local BgFrame = CreateFrame("Frame", nil, LedgerFrame, "BackdropTemplate")
    BgFrame:SetSize(WINDOW_WIDTH - 17, WINDOW_HEIGHT - 30)
    BgFrame:SetPoint("CENTER", LedgerFrame, "CENTER", 0, -10)
    local bg = BgFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Spellbook\\Spellbook-Page-1")
    bg:SetAllPoints(LedgerFrame)
    bg:SetTexCoord(0.05, 0.81, -0.03, 450/512)

    BgFrame:SetClipsChildren(true)

    --[[
    CreateFrame Arguments:
    1. The type of frame - "Frame"
    2. The global frame name - "LedgerFrame"
    3. The Parent frame (NOT a string!!!) - UIParent
    4. A comma separated LIST (string list) of XML templates to inherit from (either Blizzard's or own)
    ]]

    --[[
        "TOPLEFT"
        "TOP"
        "TOPRIGHT"
        "LEFT"
        "CENTER"
        "RIGHT"
        "BOTTOMLEFT"
        "BOTTOM"
        "BOTTOMRIGHT"
    ]]

    ---------------------
    -- Title
    ---------------------

    LedgerFrame.title = CreateTitle()

    ---------------------
    -- Scroll frame
    ---------------------

    CreateScrollFrame()

    ----------------------
    -- Test button
    ----------------------
    -- LedgerFrame.saveBtn = CreateButton("CENTER", indexPage, "TOP", -70, "Save");

    local indexPage, itemsPage, searchPage = SetTabs(3, "Index", "Items", "Search") -- returns content pages
    IndexPageContent(indexPage)
    ItemsPageContent(itemsPage)
    LedgerFrame.indexPage = indexPage
    LedgerFrame.itemsPage = itemsPage
    LedgerFrame.searchPage = searchPage

    ---------------------------
    -- Frame functionalities
    ---------------------------

    LedgerFrame:EnableMouse(true)
    LedgerFrame:SetMovable(true)
    LedgerFrame:RegisterForDrag("LeftButton")
    LedgerFrame:SetScript("OnDragStart", function(self)
	    self:StartMoving()
    end)
    LedgerFrame:SetScript("OnDragStop", function(self)
	    self:StopMovingOrSizing()
    end)
    LedgerFrame:SetScript("OnShow", function()
        PlaySound(3190)
    end)

    LedgerFrame:SetScript("OnHide", function()
        PlaySound(3191)
    end)
    LedgerFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)
    
    return LedgerFrame
end


