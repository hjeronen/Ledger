---------------------------------------------
-- MAIL LOGGER
---------------------------------------------

local MailLogger = CreateFrame("Frame", UIParent)

--[[
    Mailbox content is kept in state that is updated on event MAIL_INOBX_UPDATE.
    If new state has different items than old state, this indicates that an item
    was removed (e.g. money was collected). Then the item data should be fetched
    from old state and added to LedgerData.

    NOTE: Monitoring only Auction House data!!!

    On event MAIL_INBOX_UPDATE:
    1. Check if old state exists, if not initialize it.
    2. Get current mailbox content to new state.
    3. Check if old state and new state match.
    4. If states do not match, get missing item from old state.
    5. Update item data to LedgerData.
    6. Set new state to old state.
]]

function UseMailLogger()
    LedgerPrint("Using mail logger")
    MailLogger.items = {}
    MailLogger.initialMailCount = 0

    MailLogger:RegisterEvent("MAIL_INBOX_UPDATE") -- Might be better to use MAIL_SHOW, and record data when mail is opened

    MailLogger:SetScript("OnEvent", function(self, event, ...)
        if event == "MAIL_INBOX_UPDATE" then
            if MailLogger.mailUpdateTimer then
                MailLogger.mailUpdateTimer:Cancel()
            end

            MailLogger.mailUpdateTimer = C_Timer.NewTimer(0.5, function()
                MailLogger:PrintMoneyInMailbox()
                MailLogger:RecordMail()
                UpdateLedger()
            end)
        end
    end)
end

function MailLogger:RecordMail()
    local numMail = GetInboxNumItems()
    local currentItems = {}

    local listIndex = 1 -- for indexing currentItems
    for i = 1, numMail do -- i is for indexing mailbox items
        local _packageIcon, _stationeryIcon, sender, subject, money = GetInboxHeaderInfo(i)
        if sender and string.find(sender, "Auction House") then
            if (subject and string.find(subject, "Auction successful")) then
                local count = tonumber(string.match(subject, "%((%d+)%)"))
                local itemName = string.match(subject, "Auction successful: (.+) ?%(") or string.match(subject, "Auction successful: (.+)")

                if itemName then
                    itemName = itemName:match("^%s*(.-)%s*$") -- remove whitespace
                end

                if itemName and not count then
                    count = 1
                end

                local identifier = MailLogger:GetTableKey({
                    name = itemName,
                    count = count,
                    money = money,
                })

                currentItems[listIndex] = {
                    index = listIndex,
                    identifier = identifier,
                    name = itemName,
                    count = count,
                    money = money,
                    subject = subject,
                }

                listIndex = listIndex + 1

            elseif (subject and string.find(subject, "Auction expired")) then
                local name, _itemId, _itemTexture, count = GetInboxItem(i, 1)
                local itemName = name -- leave nil to correctly detect collected items! See CompareLoggerData()
                if name then
                    itemName = name:match("^%s*(.-)%s*$")
                end

                local identifier = MailLogger:GetTableKey({
                    name = itemName,
                    count = count,
                    money = 0,
                })

                currentItems[listIndex] = {
                    index = listIndex,
                    identifier = identifier,
                    name = itemName,
                    count = count,
                    money = 0,
                    subject = subject,
                }

                listIndex = listIndex + 1
            end

            -- print("Logged item:")
            -- for j, item in ipairs(currentItems) do
            --     if item.index == i then
            --         print(item.name)
            --         print(item.count)
            --         print(item.money)
            --     end
            -- end
        end
    end

    -- When first opening the mailbox, initialize MailLogger.items
    -- and do not update Ledger.
    if IsEmptyTable(MailLogger.items) then
        MailLogger.items = currentItems
        MailLogger.initialMailCount = numMail
        return
    end

    -- All mail might not load at once, so keep updating MailLogger.items
    if numMail > MailLogger.initialMailCount then
        MailLogger.items = currentItems
        MailLogger.initialMailCount = numMail
        return
    end

    MailLogger:UpdateLedgerData(MailLogger:CompareLoggerData(currentItems))
    MailLogger.items = currentItems
end

function MailLogger:GetTableKey(item)
    local key = string.format("%s%d%d", item.name or "unknown", item.count or 0, item.money or 0)
    return key
end


function MailLogger:CompareLoggerData(currentItems)
    local removedItems = {}
    local currentItemsIndex = 1

    for i, item in ipairs(MailLogger.items) do
        -- Hack: when money or item is collected from mail, the mail is not immediately deleted,
        -- but stays in the mailbox as empty. Then the compare loop would interpret the next item
        -- as removed from mailbox because it is different from what is in current index.
        -- If some item.name is nil, cannot reliably compare lists.
        if not item.name then
            break
        end

        local currentItem = currentItems[currentItemsIndex] or {}
        
        if item.identifier ~= (currentItem.identifier or "N/A" ) then
            LedgerPrint("Removed item: "..item.name)
            table.insert(removedItems, item)
            currentItemsIndex = currentItemsIndex - 1
        end

        currentItemsIndex = currentItemsIndex + 1
    end

    return removedItems
end

function MailLogger:UpdateLedgerData(updateItems)
    for _i, item in pairs(updateItems) do
        local name = item.name
        local count = item.count
        local money = item.money
        local subject = item.subject
        
        if not LedgerData.items[name] then
            LedgerData.items[name] = {
                name = name,
                successfulAuctionsCount = 0,
                failedAuctionsCount = 0,
                totalMoneyEarned = 0,
                highestSoldUnitPrice = 0,
                lowestSoldUnitPrice = nil,
            }
        end

        if (subject and string.find(subject, "Auction successful")) then
            local oldData = LedgerData.items[name] or {}

            local unitPrice = math.floor((money / count) + 0.5)

            local highestUnitPrice = oldData.highestSoldUnitPrice or 0
            if unitPrice > highestUnitPrice then
                highestUnitPrice = unitPrice
            end

            local lowestUnitPrice = oldData.lowestSoldUnitPrice or 0
            if unitPrice < lowestUnitPrice or lowestUnitPrice == 0 then
                lowestUnitPrice = unitPrice
            end
            
            local newData = { 
                name = name,
                successfulAuctionsCount = (oldData.successfulAuctionsCount or 0) + count,
                failedAuctionsCount = oldData.failedAuctionsCount,
                totalMoneyEarned = (oldData.totalMoneyEarned or 0) + money,
                highestSoldUnitPrice = highestUnitPrice,
                lowestSoldUnitPrice = lowestUnitPrice,
            }

            LedgerData.items[name] = newData

        elseif (subject and string.find(subject, "Auction expired")) then
            local oldData = LedgerData.items[name] or {}
            local newData = { 
                name = name,
                successfulAuctionsCount = oldData.successfulAuctionsCount,
                failedAuctionsCount = (oldData.failedAuctionsCount or 0) + count,
                totalMoneyEarned = oldData.totalMoneyEarned,
                highestSoldUnitPrice = oldData.highestSoldUnitPrice,
                lowestSoldUnitPrice = oldData.lowestSoldUnitPrice,
            }

            LedgerData.items[name] = newData
        end
        LedgerPrint("Updated to ledger: "..name)
    end
end

function MailLogger:CountMoneyInMailbox()
    local numMail = GetInboxNumItems()
    local sum = 0

    for i = 1, numMail do
        local _packageIcon, _stationeryIcon, sender, subject, money = GetInboxHeaderInfo(i)
        if sender and string.find(sender, "Auction House") then
            sum = sum + money
        end
    end

    return sum
end

function MailLogger:PrintMoneyInMailbox()
    LedgerPrint("Money in mailbox: "..ParseMoney(CountMoney(MailLogger:CountMoneyInMailbox())))
end