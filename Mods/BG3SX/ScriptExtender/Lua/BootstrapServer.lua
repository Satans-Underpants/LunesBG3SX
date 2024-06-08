Ext.Require("Data/AnimationPack.lua")
Ext.Require("Data/BodyLibrary.lua")

Ext.Require("Utils/Helper.lua")
Ext.Require("Utils/Table.lua")
Ext.Require("Utils/Entity.lua")

Ext.Require("Server/BG3SX.lua")
Ext.Require("Server/Genitals.lua")
Ext.Require("Server/NPCStripping.lua")
Ext.Require("Server/UserSettings.lua")
Ext.Require("Server/SexActor.lua")
Ext.Require("Server/PairedAnimation.lua")
Ext.Require("Server/SoloAnimation.lua")
Ext.Require("Server/ActorScale.lua")



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