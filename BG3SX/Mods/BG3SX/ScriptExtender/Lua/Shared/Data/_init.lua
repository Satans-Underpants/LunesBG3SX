-- Initialize ModEvents List
Ext.Require("Shared/Data/ModEvents.lua")
-- Initialize Data
Ext.Require("Shared/Data/Sounds.lua") -- Initialize before AnimationData so it actually gets its soundTables
Ext.Require("Shared/Data/AnimationData.lua")
Ext.Require("Shared/Data/BodyLibrary.lua")
Ext.Require("Shared/Data/Equipment.lua")
Ext.Require("Shared/Data/Statuses.lua")
Ext.Require("Shared/Data/Origins.lua")
Ext.Require("Shared/Data/SceneTypes.lua")
Ext.Require("Shared/Data/Spells.lua") -- Initialize Spells after SceneTypes to allow usage of Spells:AddSpellsToContainerBySceneType which iterated over SceneTypes
-- Initialize White-/Blacklists
Ext.Require("Shared/Data/Whitelist.lua")
Ext.Require("Shared/Data/WhitelistCompatibility.lua")
-- Initialize AnimationSets being added to BG3AF
Ext.Require("Shared/Data/AnimationSets.lua")