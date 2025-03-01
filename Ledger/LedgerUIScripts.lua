-- quicker ui reload
SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

-- quicker access to frame stack
SLASH_FRAMESTK1 = "/fs"
SlashCmdList.FRAMESTK = function()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

-- use left and right arrow keys in the edit box
for i = 1, NUM_CHAT_WINDOWS do
    _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end

-- open Ledger
SLASH_OPENLEDGER1 = "/ledger"
SlashCmdList.OPENLEDGER = OpenLedgerHandler