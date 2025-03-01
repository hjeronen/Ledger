--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Config = {} -- adds Config table to addon namespace
local Config = core.Config

-----------------------------------------
-- Default settings - not implemented yet
-----------------------------------------
local defaults = {}

--------------------------------------
-- Ledger setup
--------------------------------------

--[[
	Schema for LedgerData:

	LedgerData = {
		items = {
			[itemName] = {
				name = 'Copper Bar'
				successfulAuctionsCount = 10 -- how many items sold
				failedAuctionsCount = 5 -- how many times tried to sell
				totalMoneyEarned = 12345 -- in coppers
				highestSoldUnitPrice = 10000
				lowestSoldUnitPrice = 1000
			}
		}
	}
]]