---------------------------------
-- COMMON UTILITY FUNCTIONS
---------------------------------


function IsEmptyTable(tbl)
    return type(tbl) == "table" and next(tbl) == nil
end


function SuccessCount()
    local count = 0
    local items = LedgerData.items or {}

    if IsEmptyTable(items) then
        return count
    end

    for i, item in pairs(items) do
        count = count + (item.successfulAuctionsCount or 0)
    end

    return count
end


function FailedCount()
    local count = 0
    local items = LedgerData.items or {}

    for i, item in pairs(items) do
        count = count + (item.failedAuctionsCount or 0)
    end

    return count
end


function TotalMoneyCount()
    local count = 0
    local items = LedgerData.items or {}

    for i, item in pairs(items) do
        count = count + (item.totalMoneyEarned or 0)
    end

    return count
end


function CountMoney(coppers)
    if not coppers then
        return 0
    end
    local gold = (coppers - (coppers % 10000)) / 10000
    local silver = ((coppers % 10000) - (coppers % 100)) / 100
    local copper = (coppers % 100)
    return unpack({ gold, silver, copper })
end


function ParseMoney(gold, silver, copper)
    return ""..(gold or 0).."g "..(silver or 0).."s "..(copper or 0).."c"
end


function PrintTable(t, indt)
    local indent = indt or 0
    if type(t) ~= "table" then
        print("Not a table:", t)
        return
    end

    for key, value in pairs(t) do
        local spacing = string.rep("  ", indent) -- Indentation for readability
        if type(value) == "table" then
            print(spacing .. tostring(key) .. " = {")
            PrintTable(value, indent + 1) -- Recursively print nested tables
            print(spacing .. "}")
        else
            print(spacing .. tostring(key) .. " = " .. tostring(value))
        end
    end
end


function SortItemsByName(items)
    if not items then return {} end

    local sortedList = {}
    for _key, item in pairs(items) do
        if item.name then
            table.insert(sortedList, item)
        end
    end

    -- Sort alphabetically by name
    table.sort(sortedList, function(a, b) return a.name < b.name end)

    return sortedList
end


function GetDuplicateItems()
    local sorted = SortItemsByName(LedgerData.items)

    local duplicates = {}
    local prevName = ""

    for _i, item in pairs(sorted) do
        if item.name:match("^%s*(.-)%s*$") == prevName then
            table.insert(duplicates, item)
        end
        prevName = item.name
    end

    print("Duplicate items: ")

    for _i, item in pairs(duplicates) do
        print(item.name)
    end
end


--[[
    Cleans and merges duplicate items in `LedgerData.items`.

    This function ensures that all items are uniquely stored by name.
    - Trims any leading or trailing spaces from item names.
    - Merges duplicate entries by summing successful and failed auctions.
    - Updates total money earned.
    - Ensures highest and lowest unit prices are recorded correctly.

    NOTE: Updating the lowest price does not work correctly if it is nil.

    Usage:
        Call `CleanUpAndMergeData()` to sanitize `LedgerData.items`.
    
    Modifies:
        LedgerData.items (Directly updates the database)
]]
function CleanUpAndMergeData()
    LedgerPrint("CLEANING UP DATABASE")
    local newData = {}
    for _i, item in pairs(LedgerData.items) do
        local itemName = item.name:match("^%s*(.-)%s*$")
        
        if not newData[itemName] then
            newData[itemName] = {
                name = itemName,
                successfulAuctionsCount = item.successfulAuctionsCount or 0,
                failedAuctionsCount = item.failedAuctionsCount or 0,
                totalMoneyEarned = item.totalMoneyEarned or 0,
                highestSoldUnitPrice = item.highestSoldUnitPrice or 0,
                lowestSoldUnitPrice = item.lowestSoldUnitPrice or 0,
            }
        else
            local existingItem = newData[itemName]

            existingItem.successfulAuctionsCount = existingItem.successfulAuctionsCount + item.successfulAuctionsCount
            existingItem.failedAuctionsCount = existingItem.failedAuctionsCount + item.failedAuctionsCount
            existingItem.totalMoneyEarned = existingItem.totalMoneyEarned + item.totalMoneyEarned
            existingItem.highestSoldUnitPrice = math.max(existingItem.highestSoldUnitPrice or 0, item.highestSoldUnitPrice or 0)
            existingItem.lowestSoldUnitPrice = math.min(existingItem.lowestSoldUnitPrice or 0, item.lowestSoldUnitPrice or 0)

            newData[itemName] = existingItem
        end
    end
    LedgerData.items = newData
end


function CleanUnknownNames()
    LedgerData.items["(unknown)"] = nil
end


function GetMostSoldItem()
    local mostSold = { name = "", successfulAuctionsCount = 0 }

    for _, item in pairs(LedgerData.items) do
        if ((item.successfulAuctionsCount or 0) > mostSold.successfulAuctionsCount) then
            mostSold = item
        end
    end

    return mostSold
end


function GetItemWithHighestUnitPrice()
    local highestPrice = { name = "", highestSoldUnitPrice = 0 }

    for _, item in pairs(LedgerData.items) do
        local allSold = item.successfulAuctionsCount
        if ((item.highestSoldUnitPrice or 0) > highestPrice.highestSoldUnitPrice) then
            highestPrice = item
        end
    end

    return highestPrice
end


function LedgerPrint(args)
    local legendaryColor = "|cffff8000"  -- Legendary item color in WoW
    local whiteColor = "|cffffffff" -- White (default)
    local reset = "|r"  -- Resets color to default
    print(legendaryColor.."Ledger: "..whiteColor..(args or "undefined")..reset)
end


function PrintLedgerData()
    LedgerPrint("Current ledger data:")
    for i, item in pairs(LedgerData.items) do
        LedgerPrint("Item " .. i .. ":")
        PrintTable(item)
    end
end
