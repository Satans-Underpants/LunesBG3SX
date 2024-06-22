    ------------------------------------
            -- Init Classes --
    ------------------------------------

-- Initialize Data
Ext.Require("Data/SexAnimations.lua")
Ext.Require("Data/BodyLibrary.lua")
Ext.Require("Data/EntityScale.lua")
Ext.Require("Data/Equipment.lua")
Ext.Require("Data/Statuses.lua")
Ext.Require("Data/Origins.lua")
Ext.Require("Data/Sounds.lua")
Ext.Require("Data/SceneTypes.lua")

-- Initialize Debug Class
Ext.Require("Server/Classes/_DEBUG.lua")

-- Initialize Utilities
Ext.Require("Utils/Table.lua")
Ext.Require("Utils/Entity.lua")
Ext.Require("Utils/Helper.lua")
Ext.Require("Utils/UIHelper.lua")

-- Initialize General Classes (Order intentional)
Ext.Require("Server/Classes/Sounds.lua")
Ext.Require("Server/Classes/Animation.lua")
Ext.Require("Server/Classes/Genitals.lua")
Ext.Require("Server/Classes/Actor.lua")
Ext.Require("Server/Classes/Scenes.lua")
Ext.Require("Server/Classes/Sex.lua")
-- Ext.Require("Server/Classes/Spells.lua")
-- Ext.Require("Server/Classes/Objects.lua")

-- Initialize NPCStripping
Ext.Require("Server/Classes/NPCStripping.lua")

-- Initialize Main Class and Usersettings
Ext.Require("Server/Classes/Main.lua")
Ext.Require("Server/Classes/UserSettings.lua")

-- Initialize Listeners
Ext.Require("Server/Listeners/AnimationListener.lua")
Ext.Require("Server/Listeners/GenitalListeners.lua")
Ext.Require("Server/Listeners/EntityListeners.lua")
Ext.Require("Server/Listeners/SceneListeners.lua")
Ext.Require("Server/Listeners/SexListeners.lua")

    ------------------------------------
            -- Mod Variables --
    ------------------------------------

Ext.Vars.RegisterUserVariable("ActorData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})

Ext.Vars.RegisterUserVariable("PairData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})

Ext.Vars.RegisterUserVariable("SoloData", {
    Server = true,
    Client = true, 
    SyncToClient = true
})