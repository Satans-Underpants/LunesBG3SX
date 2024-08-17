------------------------------------
        -- Init Classes --
------------------------------------

-- Initialize Events
Ext.Require("Shared/Utils/ModEvents.lua") -- Register all possible ModEvents
--Ext.Require("Shared/Utils/ModEventsTester.lua") -- Event Testing (See here how to listen to them)

-- Initialize Data Tables
Ext.Require("Shared/Data/Sounds.lua") -- Initialize before AnimationData so it actually gets its soundTables
Ext.Require("Shared/Data/AnimationData.lua")
Ext.Require("Shared/Data/BodyLibrary.lua")
Ext.Require("Shared/Data/EntityScale.lua")
Ext.Require("Shared/Data/Equipment.lua")
Ext.Require("Shared/Data/Statuses.lua")
Ext.Require("Shared/Data/Origins.lua")
Ext.Require("Shared/Data/Spells.lua")
Ext.Require("Shared/Data/SceneTypes.lua")

-- Initialize Utilities
Ext.Require("Shared/Utils/Math.lua")
Ext.Require("Shared/Utils/Table.lua")
Ext.Require("Shared/Utils/Visual.lua")
Ext.Require("Shared/Utils/Entity.lua")
Ext.Require("Shared/Utils/Helper.lua")

-- Sex
Ext.Require("Server/Classes/Sex/Genital.lua")
Ext.Require("Server/Classes/Sex/NPCStripping.lua")
Ext.Require("Server/Classes/Sex/Sex.lua")
Ext.Require("Server/Classes/Sex/SexUserVars.lua")

-- Initialize General Classes
Ext.Require("Server/Classes/Effect.lua")
Ext.Require("Server/Classes/Sound.lua")
Ext.Require("Server/Classes/Animation.lua")
Ext.Require("Server/Classes/Actor.lua")
Ext.Require("Server/Classes/Scene.lua")
Ext.Require("Server/Classes/Main.lua")

-- Initialize Usersettings
Ext.Require("Shared/Utils/UserSettings.lua")

-- Initialize Listeners
Ext.Require("Server/Listeners/GenitalListeners.lua")
Ext.Require("Server/Listeners/EntityListeners.lua")
Ext.Require("Server/Listeners/SceneListeners.lua")
Ext.Require("Server/Listeners/SexListeners.lua")