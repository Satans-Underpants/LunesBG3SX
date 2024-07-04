------------------------------------
        -- Init Classes --
------------------------------------

-- Reenable the first 2 scripts whenever Event.lua is able to sync over clients
-- Ext.Require("Shared/Data/EventSubscriber.lua") -- To have access to global subscriber table
-- Ext.Require("Shared/Utils/Event.lua") -- To be able to use event subscriptions

Ext.Require("Client/NPCSync.lua") -- Where we use event subscriptions