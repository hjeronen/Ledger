# Ledger

A World of Warcraft Classic AddOn for tracking player character's Auction House sales.

I have previous experience in using Java, Python and JavaScript, but I have never used Lua before. I created this simply as a hobby project, I will not guarantee that it will work properly (from section Bugs, you can see exactly how it does not work properly).

Ledger is still very much work in progress, use at your own peril.


## Installing

Download this Ledger repository (or just the Ledger directory) as .zip and unpack somewhere. Copy Ledger directory (the one that contains Ledger.toc at the root) to your WoW AddOns directory (/World of Warcraft/\_classic_era_/Interface/AddOns/).

**DISCLAIMER:** I have only tested this in WoW Classic (Anniversary Realms, Alliance), it might go BOOM in Retail.

When starting the game, open the AddOns window and make sure Ledger is checked.

<img src="https://github.com/user-attachments/assets/6cb88dbc-5d90-42b2-9b4b-99cbe964d746" alt="AddOnList" width="300">


## How to use

Upon login, you should see a message in your chat window stating that Ledger has been initialized. When starting the add on for the first time, there's also a notification about missing data - ignore that.

<img src="https://github.com/user-attachments/assets/8da4596b-d226-435f-a711-0dd266060052" alt="LedgerStartup" width="300">

Open Ledger by typing /ledger to console - or it might be more convenient to create a macro for this.

![LedgerIcon](https://github.com/user-attachments/assets/065465f0-2c36-49f3-b317-999a7f9f1863)


## Key Features

Nothing fancy - Ledger will simply display data on the items you have sold/tried to sell in Auction House.
- Index page: Summary of your data
- Items page: All recorded item data
- Search page: Not implemented yet, but the idea is that this would enable searching for items, and display more details.

When the player collects mail from mailbox, data is recorded to Ledger (item name, count, money, highest/lowest unit price). Only tracks mail where the sender is Auction House.

<img src="https://github.com/user-attachments/assets/34105173-6ca8-4b1d-9ddb-80ac3e2aab2b" alt="LedgerStartup" width="300"><img src="https://github.com/user-attachments/assets/3791445a-70b9-42d2-96fc-ab205982f14e" alt="LedgerStartup" width="300">


## Planned Improvements
- [ ] Item search.
- [ ] Use MAIL_SHOW events for tracking? Might be more reliable.
- [ ] Settings for setting fonts etc.
- [ ] Other improvements to the look and code, e.g. ScrollFrame does not function properly (Items page text starts too high, and stretches too low).
- [ ] Separate class for handling database interactions.

<img src="https://github.com/user-attachments/assets/0c76869b-beda-4efc-b52b-1afcb9d77712" alt="LedgerStartup" width="300">


## Bugs
- [ ] At some point, item data was recorded twice (as you can see in the picture) - I will keep monitoring if this was a bug, or if I just messed up cleaning the database.
- [x] Lowest unit price is not recorded/updated properly. - PROBABLY FIXED
- [x] Player cannot move when Ledger window is open. - FIXED
- [x] Items page data updated only on reload - FIXED.
- [x] Duplicates in the items list - FIXED
