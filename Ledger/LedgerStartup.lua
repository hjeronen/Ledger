local function OnStartup(self, event, ...)
	local eventName = (select(1, ...))
	if eventName == 'Ledger' then
		LedgerPrint("Hello Azeroth! Starting Ledger.")
		
		if not LedgerData then
			print("Ledger data was not found!")
			LedgerData = {}
		end
		
		if not LedgerData.items then
			print("LedgerData.items was not found!")
			LedgerData.items = {}
		end

		LedgerFrame = InitializeLedgerFrame()
    	LedgerFrame:Hide()
		UseMailLogger()
	end
end

function OpenLedgerHandler()
    if LedgerFrame:IsShown() then
		LedgerFrame:Hide()
	else
		UpdateLedger()
        LedgerFrame:Show()
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnStartup)

